defmodule Primetime.JsonParser do
  @moduledoc false

  def decode_json(string) do
    Jason.decode(string)
  end

  def get_first_json(jsons_string, delimiter: delimiter) when is_binary(delimiter) do
    jsons_string |> String.trim_leading() |> String.split(delimiter, parts: 2) |> Enum.at(0)
  end
end
