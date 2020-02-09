defmodule Parser.Utility do
  def ok(value, atom) do
    {:ok, {atom, value}}
  end

  def error(message) do
    {:error, message}
  end

  def first_error(ls), do: Enum.find(ls, &is_error?(&1))

  def is_error?({:error, _}), do: true
  def is_error?(_), do: false

  def all_strings?(ls), do: is_all?(ls, :string)

  def all_numbers?(ls), do: is_all?(ls, :number)

  def all_booleans?(ls), do: is_all?(ls, :boolean)

  def is_all?(ls, atom) do
    Enum.all?(ls, fn
      {:ok, {^atom, _}} -> true
      _ -> false
    end)
  end

  def extract(atom, ast) do
    {:ok, {^atom, a}} = ast
    a
  end
end
