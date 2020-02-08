defmodule Eval do
  def main({:ok, ast, _, _, _, _}), do: e_equation(ast)
  def main({:error, message}), do: {:error, message}

  def e_equation([primitive: p]), do: e_primitive(p)
  def e_equation([formula: f]), do: e_formula(f)

  def e_primitive({:boolean, bool}), do: {:ok, bool}
  def e_primitive({:string, str}), do: {:ok, str}
  def e_primitive({:number, num}), do: {:ok, num}

  def e_formula([primitive: p]), do: e_primitive(p)
  def e_formula([function: f]), do: e_function(f)
  def e_formula([expression: e]), do: e_expression(e)

  def e_function(f), do: 1

  # need to 
  def e_expression(ls), do: 2

  def e_operation({:error, message}, _, _), do: {:error, message}
  def e_operation(_, _, {:error, message}), do: {:error, message}
  def e_operation({:ok, left}, operator, {:ok, right}), do: e_operator(operator, left, right)

  def e_operator(:add, {:number, l}, {:number, r}), do: {:ok, l + r}
  def e_operator(:subtract, {:number, l}, {:number, r}), do: {:ok, l - r}
  def e_operator(:multiply, {:number, l}, {:number, r}), do: {:ok, l * r}
  def e_operator(:divide, {:number, l}, {:number, r}), do: {:ok, l / r}
  def e_operator(:and, {:boolean, l}, {:boolean, r}), do: {:ok, l and r}
  def e_operator(:or, {:boolean, l}, {:boolean, r}), do: {:ok, l or r}
  def e_operator(_, _, _), do: {:error, "Invalid operation"}
end
