defmodule KddNotionEx.Types.Date do
  use Ecto.Type

  def type(), do: :utc_datetime

  def cast(value), do: {:ok, value}

  def load(value), do: {:ok, value}

  def dump(value), do: {:ok, value}
end
