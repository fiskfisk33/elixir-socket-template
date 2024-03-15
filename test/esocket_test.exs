defmodule ESOCKETTest do
  use ExUnit.Case
  doctest ESOCKET

  test "greets the world" do
    assert ESOCKET.hello() == :world
  end
end
