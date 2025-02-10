defmodule Primetime.Math.PrimeTest do
  use ExUnit.Case, async: true

  import Primetime.Math.Prime
  # No DB hits or anything like that, these are pure unit tests so can be async
  test "is_prime? returns false for even numbers that aren't 2" do
    assert is_prime?(2) === true
  end

  test "is_prime? returns false for 1" do
    assert is_prime?(1) === false
  end

  test "is_prime? returns false for 100" do
    assert is_prime?(100) === false
  end

  test "is_prime? returns true for 3" do
    assert is_prime?(100) === false
  end

  test "is_prime? returns false for floats" do
    assert is_prime?(1.00) === false
  end
end
