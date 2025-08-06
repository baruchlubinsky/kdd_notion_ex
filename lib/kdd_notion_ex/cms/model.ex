defmodule KddNotionEx.CMS.Model do

  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset


      @primary_key {:id, :binary_id, autogenerate: false}

      def validate_notion_db(req, id) do
        Cachex.del(:notion_databases, id)
        db_properties = KddNotionEx.Database.get_properties(req, id)
        fields = fields()

        Enum.map(fields, fn {type, name} ->
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
      end

      def fields() do
        __MODULE__.__schema__(:fields)
        |> Enum.reject(fn k -> k == :id end)
        |> Enum.map(fn field -> {__MODULE__.__schema__(:type, field), field} end)
      end

      def fields_as_properties() do
        fields()
        |> Enum.map(&KddNotionEx.CMS.Model.notion_property/1)
      end
    end
  end

  def ecto_type_to_notion_type(KddNotionEx.Types.Title), do: "title"
  def ecto_type_to_notion_type(KddNotionEx.Types.Select), do: "select"
  def ecto_type_to_notion_type(:string), do: "rich_text"
  def ecto_type_to_notion_type(number) when number in [:integer, :float, :decimal], do: "number"
  def ecto_type_to_notion_type(date) when date in [:naive_datetime, :utc_datetime], do: "date"

  def notion_property({type, name}) do
    %{
      "#{name}" => %{
        ecto_type_to_notion_type(type) => %{}
      }
    }
  end

end
