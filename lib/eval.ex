defmodule Eval do
  alias Parser.UserFunctions, as: UF
  import Parser.Utility

  def main({:ok, ast, _, _, _, _}), do: e_equation(ast) |> unwrap
  def main({:error, message, _, _, _, _}), do: {:error, message}
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

  def e_function(function_name: name, function_body: body) do
    uf = UF.fetch(name)

    case uf do
      :error -> {:error, "Invalid function name"}
      {:ok, {func}} -> e_fn(func, body)
      {:ok, {func, conditions}} -> e_function_cond(func, conditions, body)
    end
  end

  def e_fn(func, body), do: func.(Enum.map(body, fn el -> e_eval(el) end))

  def e_function_cond(func, conditions, body) do
    len = Enum.count(body)

    case conditions do
      %{len: l} when l != len -> {:error, "Wrong number of arguments passed to function"}
      %{min: min} when len < min -> {:error, "Not enough arguments passed to function"}
      %{max: max} when len > max -> {:error, "Tio many arguments passed to function"}
      _ -> e_fn(func, body)
    end
  end

  def e_expression(ls) do
    [first | rest] = ls |> Enum.map(&e_eval/1)

    case first_error([first | rest]) do
      nil ->
        rest
        |> Enum.chunk_every(2)
        |> List.foldl(first, fn [operator | {:ok, right}], {:ok, left} ->
          e_operator(operator, left, right)
        end)

      err ->
        err
    end
  end

  def e_operator(:add, {:number, l}, {:number, r}), do: {:ok, {:number, l + r}}
  def e_operator(:subtract, {:number, l}, {:number, r}), do: {:ok, {:number, l - r}}
  def e_operator(:multiply, {:number, l}, {:number, r}), do: {:ok, {:number, l * r}}
  def e_operator(:divide, {:number, l}, {:number, r}), do: {:ok, {:number, l / r}}
  def e_operator(:and, {:boolean, l}, {:boolean, r}), do: {:ok, {:bool, l and r}}
  def e_operator(:or, {:boolean, l}, {:boolean, r}), do: {:ok, {:bool, l or r}}
  def e_operator(_, _, _), do: {:error, "Invalid operation"}
end
