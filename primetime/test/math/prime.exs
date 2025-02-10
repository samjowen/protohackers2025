defmodule Primetime.Math.PrimeTest do
  use ExUnit.Case, async: true

  import Primetime.Math
  # No DB hits or anything like that, these are pure unit tests so can be async
  test "is_prime returns false for even numbers" do
    assert is_prime(2) == false
  end
end
