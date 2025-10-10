defmodule KddNotionEx.Filters do

  def put_and(existing, filter) do
    Map.update(existing, "and", [], fn f -> f ++ [filter] end)
  end

  def date_range(st, et, prop) do
     %{
      "and" => [
        %{
          "property" => prop,
          "date" => %{
            "on_or_after" => Date.to_iso8601(st, :basic)
          }
        },
        %{
          "property" => prop,
          "date" => %{
            "before" => Date.to_iso8601(et, :basic)
          }
        }
      ]
    }
  end

end
