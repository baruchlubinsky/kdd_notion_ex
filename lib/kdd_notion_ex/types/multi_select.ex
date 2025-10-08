defmodule KddNotionEx.Types.MultiSelect do
  use KddNotionEx.NotionType, ecto_type: {:array, :string}
end
