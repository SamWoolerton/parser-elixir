defmodule EvalTest do
  use ExUnit.Case
  import Eval
  doctest Eval

  test "Number" do
    assert main({:ok, [primitive: {:number, 3.0}]}) == {:ok, 3.0}
  end

  test "String" do
    assert main({:ok, [primitive: {:string, "a string"}]}) == {:ok, "a string"}
  end

  test "Boolean" do
    assert main({:ok, [primitive: {:boolean, true}]}) == {:ok, true}
  end

  test "Most basic equation" do
    assert main({:ok, [formula: [primitive: {:number, 7.0}]]}) == {:ok, 7.0}
  end

  test "Expression" do
    assert main(
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
           ) ==
             {:ok, 3.0}
  end

  test "Boolean and" do
    assert main(
             {:ok,
              [
                formula: [
                  expression: [
                    {:primitive, {:boolean, true}},
                    :and,
                    {:primitive, {:boolean, false}}
                  ]
                ]
              ]}
           ) ==
             {:ok, false}
  end

  test "Divide by 0" do
    assert main(
             {:ok,
              [
                formula: [
                  expression: [
                    {:primitive, {:number, 1.0}},
                    :divide,
                    {:primitive, {:number, 0.0}}
                  ]
                ]
              ]}
           ) ==
             {:error, "Can't divide by 0"}
  end

  test "Function: sum" do
    assert main(
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "sum"},
                    {:function_body,
                     [
                       {:primitive, {:number, 1.0}},
                       {:primitive, {:number, 2.0}},
                       {:primitive, {:number, 3.0}}
                     ]}
                  ]
                ]
              ]}
           ) == {:ok, 6}
  end

  test "Nested function" do
    assert main(
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "sum"},
                    {:function_body,
                     [
                       {:primitive, {:number, 1.0}},
                       [
                         function: [
                           {:function_name, "sum"},
                           {:function_body,
                            [
                              {:primitive, {:number, 1.0}},
                              {:primitive, {:number, 2.0}},
                              {:primitive, {:number, 3.0}}
                            ]}
                         ]
                       ],
                       {:primitive, {:number, 3.0}}
                     ]}
                  ]
                ]
              ]}
           ) == {:ok, 10}
  end

  test "Function: join" do
    assert main(
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "join"},
                    {:function_body,
                     [
                       {:primitive, {:string, " "}},
                       {:primitive, {:string, "a"}},
                       {:primitive, {:string, "b"}},
                       {:primitive, {:string, "c"}}
                     ]}
                  ]
                ]
              ]}
           ) == {:ok, "a b c"}
  end

  test "Invalid function" do
    assert main(
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "test"},
                    {:function_body,
                     [
                       {:primitive, {:number, 1.0}}
                     ]}
                  ]
                ]
              ]}
           ) == {:error, "Invalid function name"}
  end

  test "Function without enough arguments" do
    assert main(
             {:ok,
              [
                formula: [
                  function: [
                    {:function_name, "join"},
                    {:function_body,
                     [
                       {:primitive, {:string, " "}},
                       {:primitive, {:string, "a"}}
                     ]}
                  ]
                ]
              ]}
           ) == {:error, "Not enough arguments passed to function"}
  end
end
