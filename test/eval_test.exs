defmodule EvalTest do
  use ExUnit.Case
  doctest Eval

  test "greets the world" do
    assert Eval.main() == :world
  end
end
