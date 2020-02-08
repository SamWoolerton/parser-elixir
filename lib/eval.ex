defmodule Eval do
  def main({:ok, ast, _, _, _, _}), do: e_equation(ast)
  def main({:error, message}), do: {:error, message}

  def e_equation([primitive: p]), do: e_primitive(p)
  def e_equation([formula: f]), do: e_formula(f)

  def e_primitive({:boolean, bool}), do: bool
  def e_primitive({:string, str}), do: str
  def e_primitive({:number, num}), do: num

  def e_formula([primitive: p]), do: e_primitive(p)
  def e_formula([function: f]), do: e_function(f)
  def e_formula([expression: e]), do: e_expression(e)

  def e_function(f), do: 1

  def e_expression(e), do: 2
end
