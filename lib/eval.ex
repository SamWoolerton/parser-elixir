defmodule Eval do
  alias Parser.UserFunctions, as: UF

  def main({:ok, ast, _, _, _, _}), do: e_equation(ast) |> unwrap
  def main({:error, message}), do: {:error, message}

  def unwrap({:error, message}), do: {:error, message}
  def unwrap({:ok, p}), do: e_primitive(p)

  def e_equation(primitive: p), do: e_primitive(p)
  def e_equation(formula: f), do: e_formula(f)

  def e_primitive({:boolean, bool}), do: {:ok, bool}
  def e_primitive({:string, str}), do: {:ok, str}
  def e_primitive({:number, num}), do: {:ok, num}

  def e_formula(primitive: p), do: e_primitive(p)
  def e_formula(function: f), do: e_function(f)
  def e_formula(expression: e), do: e_expression(e)

  def e_eval(primitive: p), do: {:ok, p}
  def e_eval(function: f), do: e_function(f)
  def e_eval(expression: e), do: e_expression(e)
  def e_eval({:primitive, p}), do: {:ok, p}
  def e_eval({:function, f}), do: e_function(f)
  def e_eval({:expression, e}), do: e_expression(e)

  # TODO: functions with explicit arity; reject if invalid
  def e_function(function_name: name, function_body: body),
    do: e_function_eval(UF.fetch(name), body)

  def e_function_eval(:error, _), do: {:error, "Invalid function name"}
  def e_function_eval({:ok, {f}}, body), do: f.(Enum.map(body, fn el -> e_eval(el) end))

  def e_expression([first | rest]) do
    rest
    |> Enum.chunk_every(2)
    |> List.foldl(e_eval(first), fn [operator | right], left ->
      e_operation(left, operator, e_eval(right))
    end)
  end

  def e_operation({:error, message}, _, _), do: {:error, message}
  def e_operation(_, _, {:error, message}), do: {:error, message}
  def e_operation({:ok, left}, operator, {:ok, right}), do: e_operator(operator, left, right)

  def e_operator(:add, {:number, l}, {:number, r}), do: {:ok, {:number, l + r}}
  def e_operator(:subtract, {:number, l}, {:number, r}), do: {:ok, {:number, l - r}}
  def e_operator(:multiply, {:number, l}, {:number, r}), do: {:ok, {:number, l * r}}
  def e_operator(:divide, {:number, l}, {:number, r}), do: {:ok, {:number, l / r}}
  def e_operator(:and, {:boolean, l}, {:boolean, r}), do: {:ok, {:bool, l and r}}
  def e_operator(:or, {:boolean, l}, {:boolean, r}), do: {:ok, {:bool, l or r}}
  def e_operator(_, _, _), do: {:error, "Invalid operation"}
end
