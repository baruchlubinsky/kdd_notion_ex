defmodule KddNotionEx.Types.Date do
  use KddNotionEx.NotionType, ecto_type: :utc_datetime

  def load({v, _}), do: {:ok, v}  
end
