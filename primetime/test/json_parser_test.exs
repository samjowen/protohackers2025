defmodule Primetime.JsonParserTest do
  use ExUnit.Case, async: true

  import Primetime.JsonParser

  test "it can split according to no delimiter" do
    test_string = ~s({"method":"isPrime","number" :123})
    split_string = get_first_json(test_string)
    assert test_string == split_string
  end
end
