defmodule KddNotionEx.Transform do
  require Logger

  def table_to_options(data, column) do
    Enum.flat_map(data, fn
      %{"id" => id, "properties" => %{^column => value}} -> [{parse_property(value), id}]
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

  def page_as_record(page, model) do
    model.load(page)
  end

  def parse_date(string) when is_nil(string), do: nil

  # Dates without times in DD-MM-YYYY
  def parse_date(string) when byte_size(string) == 10 do
    case Date.from_iso8601(string) do
      {:ok, dt} -> dt
      {:error, :invalid_format} ->
        Logger.warning("Invalid date string #{string}")
        string
      end
  end

  def parse_date(string) do
    case DateTime.from_iso8601(string) do
      {:ok, dt, _offset} ->
        dt
      {:error, :invalid_format} ->
        Logger.warning("Invalid date string #{string}")
        string
      end
  end

  def parse_property(%{"string" => value, "type" => "string"}), do: value
  def parse_property(%{"email" => value, "type" => "email"}), do: value
  def parse_property(%{"url" => value, "type" => "url"}), do: value
  def parse_property(%{"number" => value, "type" => "number"}), do: value
  def parse_property(%{"phone_number" => value, "type" => "phone_number"}), do: value
  def parse_property(%{"checkbox" => value, "type" => "checkbox"}), do: value
  def parse_property(%{"relation" => [%{"id" => value}], "type" => "relation"}), do: value
  def parse_property(%{"relation" => value, "type" => "relation"}), do: value
  def parse_property(%{"title" => [%{"plain_text" => value}], "type" => "title"}), do: value
  def parse_property(%{"rich_text" => [], "type" => "rich_text"}), do: ""
  def parse_property(%{"rich_text" => [%{"plain_text" => value}], "type" => "rich_text"}), do: value
  def parse_property(%{"date" => %{"start" => start_time, "end" => end_time}, "type" => "date"}), do: {parse_date(start_time), parse_date(end_time)}
  def parse_property(%{"date" => %{"start" => value}, "type" => "date"}), do: parse_date(value)
  def parse_property(%{"formula" => prop, "type" => "formula"}), do: parse_property(prop)
  def parse_property(%{"rollup" => prop, "type" => "rollup"}), do: parse_property(prop)
  def parse_property(%{"select" => %{"name" => value}, "type" => "select"}), do: value
  def parse_property(%{"status" => %{"name" => value}, "type" => "status"}), do: value
  def parse_property(%{"unique_id" => %{"number" => number, "prefix" => prefix}, "type" => "unique_id"}) when is_nil(prefix), do: "#{number}"
  def parse_property(%{"unique_id" => %{"number" => number, "prefix" => prefix}, "type" => "unique_id"}), do: "#{prefix}-#{number}"
  def parse_property(%{"multi_select" => values, "type" => "multi_select"}), do: Enum.map(values, fn v -> v["name"] end)

  def parse_property(%{"created_time" => value, "type" => "created_time"}), do: parse_date(value) 
  def parse_property(%{"updated_time" => value, "type" => "updated_time"}), do: parse_date(value) 

  def parse_property(%{"array" => [prop]}), do: parse_property(prop)

  def parse_property(other), do: other

end
