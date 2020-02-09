defmodule ParserTest do
  use ExUnit.Case
  import Parser
  doctest Parser

  test "Parse number" do
    assert main("3") == {:ok, [primitive: {:number, 3.0}]}
  end
end

