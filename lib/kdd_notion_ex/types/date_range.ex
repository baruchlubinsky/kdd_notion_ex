defmodule KddNotionEx.Types.DateRange do
  use KddNotionEx.NotionType, ecto_type: {:array, :utc_datetime}

  def load({start_time, end_time}), do: {:ok, [start_time, end_time]}

  def dump([start_time, end_time]), do: {:ok, {start_time, end_time}}
end
