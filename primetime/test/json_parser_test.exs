defmodule Primetime.JsonParserTest do
  use ExUnit.Case, async: true

  import Primetime.JsonParser

  test "it can split according to no delimiter" do
    test_string = ~s({"method":"isPrime","number" :123})
    split_string = get_first_json(test_string, delimiter: <<10>>)
    assert test_string == split_string
  end

  test "it can split according to a delimiter" do
    test_string = ~s(#{<<10>>}{"method":"isPrime","number" :123})
    split_string = get_first_json(test_string, delimiter: <<10>>)
    assert split_string == ~s({"method":"isPrime","number" :123})
  end
end
