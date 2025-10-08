defmodule KddNotionEx.Types.DateRange do
  use Ecto.Type

  def type(), do: {:array, :utc_datetime}

  def cast({start_time, end_time}), do: {:ok, [start_time, end_time]}
  def cast(value), do: {:ok, value}

  def load({start_time, end_time}), do: {:ok, [start_time, end_time]}
  def load(value), do: {:ok, value}

  def dump([start_time, end_time]), do: {:ok, {start_time, end_time}}
  def dump(value), do: {:ok, value}
end
