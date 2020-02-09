defmodule ParserTest do
  use ExUnit.Case
  import Parser
  doctest Parser

  test "Number" do
    assert main("3") == {:ok, [primitive: {:number, 3.0}]}
  end

  test "String" do
    assert main("\"a string\"") == {:ok, [primitive: {:string, "a string"}]}
  end

  test "Boolean" do
    assert main("true") == {:ok, [primitive: {:boolean, true}]}
  end

  test "Most basic equation" do
    assert main("=7") == {:ok, [formula: [primitive: {:number, 7.0}]]}
  end

  test "Expression" do
    assert main("=1 + 2") ==
             {:ok,
              [
                formula: [
                  expression: [
                    {:primitive, {:number, 1.0}},
                    :add,
                    {:primitive, {:number, 2.0}}
                  ]
                ]
              ]}
  end

  test "Function: sum" do
    assert main("=sum(1,2,3)") ==
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "sum"},
                    {:function_body, [
                      {:primitive, {:number, 1.0}},
                      {:primitive, {:number, 2.0}},
                      {:primitive, {:number, 3.0}},
                    ]}
                  ]
                ]
              ]}
  end

  test "Function: join" do
    assert main(~s|=join(" ","a","b","c")|) ==
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "join"},
                    {:function_body, [
                      {:primitive, {:string, " "}},
                      {:primitive, {:string, "a"}},
                      {:primitive, {:string, "b"}},
                      {:primitive, {:string, "c"}}
                    ]}
                  ]
                ]
              ]}
  end
end
