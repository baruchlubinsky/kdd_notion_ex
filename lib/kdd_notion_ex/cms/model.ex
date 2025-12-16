defmodule KddNotionEx.CMS.Model do

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      alias KddNotionEx.Types

      @primary_key {:id, :binary_id, autogenerate: false}
      @foreign_key_type :binary_id

      def validate_notion_ds(req, id) do

          Req.get(req, url: "/data_sources/#{id}")
          |> case do
            {:ok, %Req.Response{status: 200, body: response}} ->
              db_properties = response["properties"]

              Enum.map(fields(), fn {type, name} ->
                if Map.has_key?(db_properties, "#{name}") do
                  if Map.has_key?(db_properties["#{name}"], KddNotionEx.CMS.Model.ecto_type_to_notion_type(type)) do
                    :ok
                  else
                    {:error, "#{name} has wrong type, expected #{KddNotionEx.CMS.Model.ecto_type_to_notion_type(type)}."}
                  end
                else
                  {:error, "#{name} is missing from Notion properties."}
                end
              end)
              Enum.map(relations(), fn{_type, _cardinality, name} ->
                if Map.has_key?(db_properties, "#{name}") do
                  if Map.has_key?(db_properties["#{name}"], "relation") do
                    :ok
                  else
                    {:error, "#{name} has wrong type, expected relation."}
                  end
                else
                  {:error, "#{name} is missing from Notion properties."}
                end
              end)
            {:ok, %Req.Response{status: 400, body: response}} ->
              [error: response["message"]]
            {:ok, %Req.Response{status: 404, body: response}} ->
              [error: "404 Not found. Please confirm that the integration has access to that page."]
          end

      end

      def validate_notion_ds!(req, id) do
        fields = validate_notion_ds(req, id)

        if Enum.any?(fields, fn f -> f != :ok end) do
          raise fields
        end

        :ok
      end

      def fields() do
        __MODULE__.__schema__(:fields)
        |> Enum.reject(fn k -> k == :id end)
        |> Enum.map(fn field -> {__MODULE__.__schema__(:type, field), field} end)
      end

      def relations() do
        __MODULE__.__schema__(:associations)
        |> Enum.map(fn assoc -> __MODULE__.__schema__(:association, assoc) end)
        |> Enum.map(fn assoc -> {assoc.related, assoc.cardinality, assoc.field} end)
      end

      def fields_as_properties() do
        fields()
        |> Enum.map(&KddNotionEx.CMS.Model.notion_property/1)
      end

      def field_names() do
        fields()
        |> Enum.map(fn {_type, name} -> name end)
      end

      def load(params) do
        changeset(__MODULE__, params)
        |> apply_changes()
      end

      def changeset(changeset \\ __MODULE__, params)

      def changeset(changeset, %{"id" => id, "properties" => _} = params) do
        properties = Map.get(params, "properties", %{})

        changeset =
          cast(struct(changeset, id: params["id"]), properties, field_names())

        if length(relations()) == 0 do
          changeset
        else
          Enum.filter(relations(), fn {_, _, field} ->
            "#{field}" in Map.keys(properties)
          end)
          |> Enum.reduce(changeset, 
            fn {related, :one, field}, acc ->
              value = 
                case properties["#{field}"]["relation"] do
                  [] -> nil
                  data -> related.changeset(hd(data))
                end
              put_assoc(acc, field, value)
            {related, :many, field}, acc ->
              put_assoc(acc, field, Enum.map(properties["#{field}"]["relation"], fn r -> related.changeset(r) end))
            end)
          end
      end

      def changeset(changeset, %{"id" => id}) do
        change(struct(changeset, id: id))
      end

      def changeset(changeset, params) do
        cast(struct(changeset), params, field_names())
      end

      defoverridable(load: 1)

    end
  end

  def ecto_type_to_notion_type(KddNotionEx.Types.Text), do: "rich_text"
  def ecto_type_to_notion_type(KddNotionEx.Types.Number), do: "number"
  def ecto_type_to_notion_type(KddNotionEx.Types.Date), do: "date"
  def ecto_type_to_notion_type(KddNotionEx.Types.DateRange), do: "date"
  def ecto_type_to_notion_type(KddNotionEx.Types.Phone), do: "phone"
  def ecto_type_to_notion_type(KddNotionEx.Types.Formula), do: "formula"
  def ecto_type_to_notion_type(KddNotionEx.Types.Files), do: "files"
  def ecto_type_to_notion_type(KddNotionEx.Types.Title), do: "title"
  def ecto_type_to_notion_type(KddNotionEx.Types.Select), do: "select"
  def ecto_type_to_notion_type(KddNotionEx.Types.MultiSelect), do: "multi_select"
  def ecto_type_to_notion_type(KddNotionEx.Types.Checkbox), do: "checkbox"
  def ecto_type_to_notion_type(KddNotionEx.Types.URL), do: "url"
  def ecto_type_to_notion_type(KddNotionEx.Types.Email), do: "email"
  def ecto_type_to_notion_type(KddNotionEx.Types.UniqueID), do: "unqiue_id"
  def ecto_type_to_notion_type(:string), do: "rich_text"
  def ecto_type_to_notion_type(:id), do: "id"

  def ecto_type_to_notion_type(number) when number in [:integer, :float, :decimal], do: "number"
  def ecto_type_to_notion_type(date) when date in [:naive_datetime, :utc_datetime, :date], do: "date"

  def notion_property({type, name}, value \\ %{}) do
    %{
      "#{name}" => %{
        ecto_type_to_notion_type(type) => value
      }
    }
  end

  def serialize(record) do
    record.__struct__.fields()
    |> Enum.reject(fn {_type, field} -> is_nil(Map.get(record, field)) end)
    |> Enum.map(fn {type, field} ->
      KddNotionEx.CMS.Properties.serialize(type, field, Map.fetch!(record, field))
    end)
    |> Enum.reduce(%{}, fn e, acc -> Map.merge(acc, e) end )
  end

end
