defmodule Parser.UserFunctions do
  def fetch(name) do
    functions() |> Map.fetch(name)
  end

  def functions do
    functions = %{
      "sum" => {
        fn ls ->
          if all_numbers(ls) do
            ls
            |> Enum.map(&extract(:number, &1))
            |> Enum.sum
            |> ok(:number)
          else
            {:error, "sum only works on numbers"}
          end
        end
      },
      "join" => {
        fn
          [{:error, message} | _] ->
            {:error, message}

          [{:ok, {:string, sep}} | ls] ->
            if all_strings(ls) do
              ls |> Enum.map(&extract(:string, &1)) |> Enum.join(sep) |> ok(:string)
            else
              {:error, "Arguments to join must all be strings"}
            end

          [{:ok, _} | _] ->
            {:error, "Join separator must be a string"}
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

  def all_strings(ls), do: is_all?(ls, :string)

  def all_numbers(ls), do: is_all?(ls, :number)

  def all_booleans(ls), do: is_all?(ls, :boolean)

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
