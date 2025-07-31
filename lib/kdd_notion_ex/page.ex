defmodule KddNotionEx.Page do

  def get(req, page_id) do
    Req.get!(req, url: "/pages/#{page_id}")
  end

  def fetch(req, page_id) do
    {_, data} = Cachex.fetch(:notion_pages, page_id, fn id ->
      {
        :commit,
        get(req, id)
        |> KddNotionEx.Client.response()
      }
    end)
    data
  end

  def create_record(req, properties, database_id) do
    payload = %{
      parent: %{database_id: database_id},
      properties: properties
    }
    data =
    Req.post!(req, url: "/pages", json: payload)
    |> KddNotionEx.Client.response()

    Cachex.put(:notion_pages, data["id"], data)
    data
  end

  def update(req, properties, page_id) do
    payload = %{
      properties: properties
    }

    data =
    Req.patch!(req, url: "/pages/#{page_id}", json: payload)
    |> KddNotionEx.Client.response()

    Cachex.put(:notion_pages, data["id"], data)
    data
  end
end
