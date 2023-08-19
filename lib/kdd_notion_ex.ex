defmodule KddNotionEx do
  @moduledoc false

  use Supervisor

  @impl true
  def init(args) do
    args
  end

  def start_link(_args) do
    children = [
      {Finch, name: KddNotionEx.Api.ps()}
    ]

    opts = [strategy: :one_for_one, name: KddNotionEx.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
