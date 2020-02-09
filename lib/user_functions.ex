defmodule Parser.UserFunctions do
  import Parser.Utility

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
end
