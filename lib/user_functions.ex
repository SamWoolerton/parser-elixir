defmodule Parser.UserFunctions do
  def fetch(name) do
    functions() |> Map.fetch(name)
  end

  def functions do
    functions = %{
      "sum" => {
        fn ls ->
          List.foldl(ls, {:ok, {:number, 0}}, fn
            {:error, message}, _ -> {:error, message}
            _, {:error, message} -> {:error, message}
            {:ok, {:number, next}}, {:ok, {:number, acc}} -> {:ok, {:number, acc + next}}
            _, _ -> {:error, "sum only works on numbers"}
          end)
        end
      }
      # TODO: join function
    }
  end
end
