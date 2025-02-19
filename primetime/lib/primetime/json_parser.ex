defmodule Primetime.JsonParser do
  @moduledoc false

  def decode_json(string) do
    Jason.decode(string)
  end

  def get_first_json(jsons_string, delimiter: delimiter) when is_binary(delimiter) do
    case String.split(String.trim_leading(jsons_string), delimiter, parts: 2) do
      [message] -> {message, ""}
      [message, new_buffer] -> {message, new_buffer}
    end
  end
end
