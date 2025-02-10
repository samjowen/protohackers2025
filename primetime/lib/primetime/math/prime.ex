defmodule Primetime.Math.Prime do
  @moduledoc false

  def is_prime(1) do
    # One is a unit, not a number. Look it up on Wikipedia.
    false
  end

  def is_prime(2) do
    true
  end

  def is_prime(number) do
    # Filter all even numbers
    case Integer.mod(number, 2) do
      0 -> false
      _ -> true
    end
  end
end
