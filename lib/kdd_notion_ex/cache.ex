defmodule KddNotionEx.Cache do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Cachex, [pages()]}, id: :notion_page_cache),
      Supervisor.child_spec({Cachex, [properties()]}, id: :notion_database_cache),
      Supervisor.child_spec({Cachex, [content()]}, id: :notion_content_cache),
      Supervisor.child_spec({Cachex, [images()]}, id: :notion_images_cache),
      Supervisor.child_spec({Cachex, [queries()]}, id: :notion_query_cache)
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KddNotionEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def pages(), do: :notion_pages

  def properties(), do: :notion_databases

  def content(), do: :notion_content

  def images(), do: :notion_images

  def images_client() do
    KddNotionEx.Client.new(Application.get_env(:kdd_notion_ex, :cms_key))
  end

  def queries(), do: :notion_queries

end
