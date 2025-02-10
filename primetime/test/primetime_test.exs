defmodule PrimetimeTest do
  use ExUnit.Case
  doctest Primetime

  test "greets the world" do
    assert Primetime.hello() == :world
  end
end
