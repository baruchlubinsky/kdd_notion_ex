defmodule KddNotionEx.Page do
  import KddNotionEx.Api

  def get(page_id, token) do
    Finch.build(:get, "https://api.notion.com/v1/pages/#{page_id}", headers(token))
    |> request!()
  end

  def fetch(page_id, token) do
    get(page_id, token)
    |> decode_response()
  end

  def decode_response(response) do
    case response do
      %Finch.Response{status: 200, body: body} ->
        Jason.decode!(body)
      end
  end

  def create_record(properties, database_id, token) do
    payload = %{
      parent: %{database_id: database_id},
      properties: properties
    }
    Finch.build(:post, "https://api.notion.com/v1/pages", headers(token), Jason.encode!(payload))
    |> request!()
  end
end
