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

  def is_json_valid?(string) do
    case decode_json(string) do
      {:ok, term} -> true
      {:error, _reason} -> false
    end
  end
end
