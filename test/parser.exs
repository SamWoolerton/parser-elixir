defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  test "greets the world" do
    assert Parser.main() == :world
  end
end
