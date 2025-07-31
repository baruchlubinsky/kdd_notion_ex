defmodule KddNotionEx.Page do

  def get(req, page_id) do
    Req.get!(req, url: "/pages/#{page_id}")
  end

  def fetch(req, page_id) do
    get(req, page_id)
    |> KddNotionEx.Client.response()
  end

  def create_record(req, properties, database_id) do
    payload = %{
      parent: %{database_id: database_id},
      properties: properties
    }
    Req.post!(req, url: "/pages", json: payload)
  end

  def update(req, properties, page_id) do
    payload = %{
      properties: properties
    }
    Req.patch!(req, url: "/pages/#{page_id}", json: payload)
    |> KddNotionEx.Client.response()
  end
end
