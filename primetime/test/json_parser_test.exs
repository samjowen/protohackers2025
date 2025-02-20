defmodule Primetime.JsonParserTest do
  use ExUnit.Case, async: true

  import Primetime.JsonStream

  test "it can split according to no delimiter" do
    test_string = ~s({"method":"isPrime","number" :123})
    {split_string, _new_buffer} = extract_first(test_string, delimiter: <<10>>)
    assert test_string == split_string
  end

  test "it can split according to a delimiter" do
    test_string = ~s(#{<<10>>}{"method":"isPrime","number" :123})
    {split_string, _new_buffer} = extract_first(test_string, delimiter: <<10>>)
    assert split_string == ~s({"method":"isPrime","number" :123})
  end

  test "it can parse a valid json string" do
    valid_json_test_string = ~s({"method":"isPrime","number" :123})
    {:ok, _term} = decode_json(valid_json_test_string)
  end

  test "it can split a buffer with three jsons and return the new buffer correctly" do
    test_string =
      ~s({"method":"isPrime","number" :123}#{<<10>>}{"method":"isPrime","number" :456}#{<<10>>}{"method":"isPrime","number" :789}
      )

    {message, new_buffer} = extract_first(test_string, delimiter: <<10>>)
    assert message == ~s({"method":"isPrime","number" :123})
    assert new_buffer == ~s({"method":"isPrime","number" :456}#{<<10>>}{"method":"isPrime","number" :789}
      )
  end

  test "it can split a buffer where the input has a cut off json" do
    test_string =
      ~s({"method":"isPrime","number" :123}#{<<10>>}{"method":"isPrime",
      )

    {message, new_buffer} = extract_first(test_string, delimiter: <<10>>)
    assert message == ~s({"method":"isPrime","number" :123})
    assert new_buffer == ~s({"method":"isPrime",
      )
  end

  describe "json validation" do
    test "it should fail json validation for a malformed json object" do
      # Malformed because it starts with a regular bracket
      # and missing end squiggly
      malformed_json = ~s(("method":"isPrime","number":123)
      assert is_json_valid?(malformed_json) == false
    end

    test "it should pass json validation for a valid json object" do
      malformed_json = ~s({"method":"isPrime","number":123})
      assert is_json_valid?(malformed_json) == true
    end

    test "it should fail json validation if method is not isPrime" do
      invalid_method_json = ~s({"method":"isEven","number":123})
      assert is_json_valid?(invalid_method_json) == false
    end

    test "it should fail json validation if number key is absent" do
      missing_number_key = ~s({"method":"isPrime"})
      assert is_json_valid?(missing_number_key) == false
    end

    test "it should fail json validation if number value is NaN" do
      nan_number = ~s({"method":"isPrime","number":"abc"})
      assert is_json_valid?(nan_number) == false
    end
  end
end
