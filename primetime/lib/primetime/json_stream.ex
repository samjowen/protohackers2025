defmodule Primetime.JsonStream do
  @moduledoc false

  def decode_json(string) do
    Jason.decode(string)
  end

  def extract_first(jsons_string, delimiter: delimiter) when is_binary(delimiter) do
    case String.split(String.trim_leading(jsons_string), delimiter, parts: 2) do
      [message] -> {message, ""}
      [message, new_buffer] -> {message, new_buffer}
    end
  end

  defp json_validation_checks(json) do
    check_json_has_valid_method(json)
  end

  defp check_json_has_valid_method(json) when is_map(json) do
    case Map.get(json, "method") do
      "isPrime" -> true
      _ -> false
    end
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
