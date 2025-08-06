defmodule KddNotionEx.Types.Title do
  use Ecto.Type
  def type(), do: :string

  def cast(title), do: {:ok, title}

  def load(title), do: {:ok, title}

  def dump(title), do: {:ok, title}
end
