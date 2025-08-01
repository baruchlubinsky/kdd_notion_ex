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
    response = Req.post!(req, url: "/pages", json: payload)

    case response do
      %Req.Response{status: 200, body: body} ->
        Cachex.put(:notion_pages, body["id"], body)
    end

    response
  end

  def update(req, properties, page_id) do
    Cachex.del(:notion_pages, page_id)
    payload = %{
      properties: properties
    }
    response = Req.patch!(req, url: "/pages/#{page_id}", json: payload)

    case response do
      %Req.Response{status: 200, body: body} ->
        Cachex.put(:notion_pages, body["id"], body)
    end

    response
  end

end
