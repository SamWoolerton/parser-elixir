defmodule Parser do
  import NimbleParsec
  import Concat

  def main(arg), do: equation(arg)

  p_true = string("true") |> replace(true) |> label("true")
  p_false = string("false") |> replace(false) |> label("false")
  p_bool = choice([p_true, p_false]) |> unwrap_and_tag(:boolean) |> label("boolean")

  p_string_inside = utf8_char([{:not, ?"}]) |> repeat |> wrap |> map({Kernel, :to_string, []})

  p_string =
    ignore(string("\""))
    <|> p_string_inside
    <|> ignore(string("\""))
    |> unwrap_and_tag(:string)
    |> label("string")

  p_integer = integer(min: 1)

  p_decimal_part =
    ignore(string("."))
    |> integer(min: 1)
    |> optional

  p_number =
    p_integer
    <|> p_decimal_part
    |> reduce({Enum, :join, ["."]})
    |> map({Float, :parse, []})
    |> map({Kernel, :elem, [0]})
    |> unwrap_and_tag(:number)
    |> label("number")

  p_primitive =
    choice([p_bool, p_string, p_number])
    |> unwrap_and_tag(:primitive)
    |> label("primitive")

  p_operator =
    choice([
      string("+") |> replace(:add) |> label("add"),
      string("-") |> replace(:subtract) |> label("subtract"),
      string("*") |> replace(:multiply) |> label("multiply"),
      string("/") |> replace(:divide) |> label("divide"),
      string("&&") |> replace(:and) |> label("and"),
      string("||") |> replace(:or) |> label("or")
    ])
    |> label("operator")

  optional_whitespace = string(" ") |> repeat |> ignore |> optional |> label("whitespace")

  p_expression_part = choice([p_primitive, parsec(:function)])

  p_expression_repeated =
    p_operator <|> optional_whitespace <|> p_expression_part |> times(min: 1)

  p_expression =
    p_expression_part
    <|> optional_whitespace
    <|> p_expression_repeated
    |> tag(:expression)
    |> label("expression")

  p_function_name =
    choice([
      utf8_char([?a..?z]),
      utf8_char([?_]),
      utf8_char([??])
    ])
    |> repeat
    |> reduce({Kernel, :to_string, []})
    |> unwrap_and_tag(:function_name)
    |> label("function name")

  p_function_argument_first =
    choice([
      parsec(:function),
      p_expression,
      p_primitive
    ])

  p_function_argument_rest =
    optional_whitespace
    <|> ignore(utf8_char([?,]))
    <|> optional_whitespace
    <|> p_function_argument_first

  p_function_body =
    p_function_argument_first
    <|> (p_function_argument_rest |> repeat)
    |> tag(:function_body)
    |> label("function body")

  p_function =
    p_function_name
    <|> ignore(string("("))
    <|> p_function_body
    <|> ignore(string(")"))
    |> tag(:function)
    |> label("function")

  defcombinatorp(
    :function,
    p_function
  )

  p_formula =
    choice([
      p_expression,
      p_primitive,
      p_function
    ])
    |> tag(:formula)
    |> label("formula")

  p_equation =
    choice([
      p_primitive,
      ignore(string("=")) <|> p_formula
    ])
    |> label("equation")

  defparsec(:equation, p_equation)
end
