defmodule KddNotionEx.Types.SelectOption do
  defstruct [:colour, :name, :description, :id]

  def from_property(data, field) do
    property = data[field]
    type = property["type"]

    Enum.map(property[type]["options"], fn o ->
      label = if is_nil(o["description"]), do: o["name"], else: o["description"]
      {label, o["name"]}
    end)
  end
end
