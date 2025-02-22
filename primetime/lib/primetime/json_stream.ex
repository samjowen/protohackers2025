defmodule Primetime.JsonStream do
  @moduledoc false

  def decode_json(string) do
    Jason.decode(string)
  end

  def extract_first(jsons_string, delimiter: delimiter) when is_binary(delimiter) do
    case String.split(jsons_string, delimiter, parts: 2) do
      # Extract first full message
      [message, new_buffer] -> {String.trim(message), new_buffer}
      # Keep the partial message in buffer
      [partial_message] -> {"", partial_message}
    end
  end

  defp check_json_has_number_key(json) when is_map(json) do
    Map.has_key?(json, "number")
  end

  defp check_json_number_is_a_number(json) when is_map(json) do
    case Map.get(json, "number") do
      nil ->
        false

      number when is_integer(number) or is_float(number) ->
        true

      _ ->
        false
    end
  end

  defp check_json_has_valid_method(json) when is_map(json) do
    case Map.get(json, "method") do
      "isPrime" -> true
      _ -> false
    end
  end

  defp json_validation_checks(json) do
    checks = [&check_json_has_number_key/1, &check_json_has_valid_method/1, &check_json_number_is_a_number/1]
    Enum.all?(checks, fn check -> check.(json) end)
  end

  def is_json_valid?(string) do
    case decode_json(string) do
      {:ok, term} ->
        if json_validation_checks(term) do
          true
        else
          false
        end

      _ ->
        false
    end
  end
end
