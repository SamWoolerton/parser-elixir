defmodule Concat do
  import NimbleParsec

  def first <|> second do
    concat(first, second)
  end
end