defmodule System2Test do
  use ExUnit.Case
  doctest System2

  test "greets the world" do
    assert System2.hello() == :world
  end
end
