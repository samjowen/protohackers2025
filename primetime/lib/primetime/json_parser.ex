defmodule Primetime.JsonParser do
  @moduledoc false

  def decode_json(string) do
    Jason.decode(string)
  end

  def get_first_json(jsons_string, delimiter: delimiter) when is_binary(delimiter) do
    split_parts = jsons_string |> String.trim_leading() |> String.split(delimiter, parts: 2)

    case length(split_parts) do
      1 -> Enum.at(split_parts, 0)
      2 -> {Enum.at(split_parts, 0), Enum.at(split_parts, 1)}
    end
  end
end
