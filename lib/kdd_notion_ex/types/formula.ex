defmodule KddNotionEx.Types.Formula do
  use Ecto.Type

  def type(), do: :string

  def cast(value), do: {:ok, value}

  def load(value), do: {:ok, value}

  def dump(value), do: {:ok, value}
end
