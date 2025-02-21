defmodule Primetime.IsPrime do
  @moduledoc false

  # Reject floats straight away.
  def is_prime?(n) when is_float(n), do: false

  # Main function for integers.
  def is_prime?(n) when is_integer(n) do
    cond do
      n <= 1 -> false
      n == 2 -> true
      rem(n, 2) == 0 -> false
      true -> check_divisor(n, 3, trunc(:math.sqrt(n)))
    end
  end

  # If no divisor is found up to the square root, the number is prime.
  defp check_divisor(_n, current, max) when current > max, do: true

  # If we find a divisor, return false. Otherwise, check the next odd number.
  defp check_divisor(n, current, max) do
    if rem(n, current) == 0 do
      false
    else
      check_divisor(n, current + 2, max)
    end
  end
end
