defmodule KddNotionEx.Page do
  import KddNotionEx.Api

  def get(page_id, token) do
    Finch.build(:get, "https://api.notion.com/v1/pages/#{page_id}", headers(token))
    |> request!()
  end

  def fetch(page_id, token) do
    get(page_id, token)
    |> read_body()
  end

  def create_record(properties, database_id, token) do
    payload = %{
      parent: %{database_id: database_id},
      properties: properties
    }
    Finch.build(:post, "https://api.notion.com/v1/pages", headers(token), Jason.encode!(payload))
    |> request!()
  end

  def update(properties, page_id, token) do
    payload = %{
      properties: properties
    }
    Finch.build(:patch, "https://api.notion.com/v1/pages/#{page_id}", headers(token), Jason.encode!(payload))
    |> request!()
    |> read_body()
  end
end
