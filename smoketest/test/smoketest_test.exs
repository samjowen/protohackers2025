defmodule SmoketestTest do
  use ExUnit.Case
  doctest Smoketest

  test "greets the world" do
    assert Smoketest.hello() == :world
  end
end
