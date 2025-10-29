defmodule KddNotionEx.Types.MultiSelect do
  use KddNotionEx.NotionType, ecto_type: {:array, KddNotionEx.Types.SelectOption}
end
