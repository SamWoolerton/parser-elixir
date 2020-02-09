defmodule Parser.UserFunctions do
  def fetch(name) do
    functions() |> Map.fetch(name)
  end

  def functions do
    %{
      "sum" => {
        fn ls ->
          case first_error(ls) do
            nil ->
              if all_numbers?(ls) do
                ls
                |> Enum.map(&extract(:number, &1))
                |> Enum.sum()
                |> ok(:number)
              else
                {:error, "sum only works on numbers"}
              end

            err ->
              err
          end
        end
      },
      "join" => {
        fn ls ->
          case first_error(ls) do
            nil ->
              if all_strings?(ls) do
                [sep | strings] = ls |> Enum.map(&extract(:string, &1))
                strings |> Enum.join(sep) |> ok(:string)
              else
                {:error, "Arguments to join must all be strings"}
              end

            err ->
              err
          end
        end,
        %{
          min: 3
        }
      }
    }
  end

  def ok(value, atom) do
    {:ok, {atom, value}}
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
