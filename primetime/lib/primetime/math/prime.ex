defmodule Primetime.Math.Prime do
  @moduledoc false

  # 1 is not prime – it's a unit.
  def is_prime?(1), do: false

  # 2 is prime.
  def is_prime?(2), do: true

  # Decimal numbers are not considered prime.
  def is_prime?(number) when is_float(number), do: false

  # For all other integers, check if the number is negative or even.
  def is_prime?(number) when is_integer(number) and number < 0, do: false
  def is_prime?(number) when is_integer(number) and rem(number, 2) == 0, do: false
  def is_prime?(number) when is_integer(number), do: true
end
