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

  def fetch_content(req, page_id, start_cursor \\ nil) do
    url = if is_nil(start_cursor) do
      "/blocks/#{page_id}/children"
    else
      "/blocks/#{page_id}/children?start_cursor=#{start_cursor}"
    end
    Req.get!(req, url: url)
    |> case do
      %Req.Response{status: 200, body: response} ->
        if response["has_more"] do
          response["results"] ++ fetch_content(req, page_id, response["next_cursor"])
        else
          response["results"]
        end
    end

    def elements(blocks) do
      Enum.reject(blocks, fn b -> b["archived"] end)
      |> Enum.map(&block_as_elements/1)
    end

    def block_as_elements(block) when is_list(block) do
      Enum.map(block, &block_as_elements/1)
    end

    def block_as_elements(%{"type" => "paragraph"} = block) do
      {:p, block_as_elements(block["paragraph"]["rich_text"])}
    end

    def block_as_elements(%{"type" => "text"} = block) do
      if is_nil(block["href"]) do
        {:s, block_as_elements(block["text"]["content"])}
      else
        {:s, {:a, block["href"], block["text"]["content"]}}
      end
    end

    def block_as_elements(%{"type" => "divider"}) do
      {:hr}
    end

  end

end
