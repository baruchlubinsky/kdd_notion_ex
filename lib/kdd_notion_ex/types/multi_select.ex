defmodule KddNotionEx.Types.MultiSelect do
  use Ecto.Type

  def type(), do: {:array, :string}

  def cast(value), do: {:ok, value}

  def load(value), do: {:ok, value}

  def dump(value), do: {:ok, value}
end
