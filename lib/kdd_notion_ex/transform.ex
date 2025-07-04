defmodule KddNotionEx.Transform do

  def table_to_options(data, column) do
    Enum.flat_map(data, fn
      %{"id" => id, "properties" => %{^column => %{"title" => [%{"plain_text" => c}]}}} -> [{c, id}]
      _ -> []
    end)

  end

  def pivot_table(data, values_prop, categories_prop) do
    Enum.map(data, fn row ->
      value = row["properties"][values_prop] |> parse_property()
      category = row["properties"][categories_prop] |> parse_property()
      {category, value}
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  def page_as_record(page) do
    Enum.reduce(page["properties"], Map.take(page, ["id"]), fn {k, v}, acc ->
      Map.merge(acc, %{k => parse_property(v)})
    end)
  end

  def parse_date(string) do
    {:ok, dt, _} = DateTime.from_iso8601(string)
    dt
  end

  def parse_property(%{"number" => value, "type" => "number"}), do: value
  def parse_property(%{"checkbox" => value, "type" => "checkbox"}), do: value
  def parse_property(%{"relation" => [%{"id" => value}], "type" => "relation"}), do: value
  def parse_property(%{"relation" => value, "type" => "relation"}), do: value
  def parse_property(%{"title" => [%{"plain_text" => value}], "type" => "title"}), do: value
  def parse_property(%{"date" => %{"start" => start_time, "end" => end_time}, "type" => "date"}), do: {parse_date(start_time), parse_date(end_time)}
  def parse_property(%{"date" => %{"start" => value}, "type" => "date"}), do: parse_date(value)
  def parse_property(%{"formula" => prop, "type" => "formula"}), do: parse_property(prop)
  def parse_property(%{"rollup" => prop, "type" => "rollup"}), do: parse_property(prop)

  def parse_property(%{"array" => [prop]}), do: parse_property(prop)

  def parse_property(other), do: other

end
