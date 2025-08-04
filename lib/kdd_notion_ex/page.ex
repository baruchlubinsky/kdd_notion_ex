defmodule KddNotionEx.Page do

  def get(req, page_id) do
    Req.get!(req, url: "/pages/#{page_id}")
  end

  def fetch(req, page_id) do
    {_, data} = Cachex.fetch(KddNotionEx.Cache.pages(), page_id, fn id ->
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
        Cachex.put(KddNotionEx.Cache.pages(), body["id"], body)
    end

    response
  end

  def update(req, properties, page_id) do
    Cachex.del(KddNotionEx.Cache.pages(), page_id)
    payload = %{
      properties: properties
    }
    response = Req.patch!(req, url: "/pages/#{page_id}", json: payload)

    case response do
      %Req.Response{status: 200, body: body} ->
        Cachex.put(KddNotionEx.Cache.pages(), body["id"], body)
    end

    response
  end

  def fetch_content(req, page_id) do
    {_, data} = Cachex.fetch(KddNotionEx.Cache.content(), page_id, fn id ->
      {
        :commit,
        Req.get!(req, url: "/blocks/#{id}/children")
        |> case do
          %Req.Response{status: 200, body: response} ->
            if response["has_more"] do
              response["results"] ++ fetch_content(req, id, response["next_cursor"])
            else
              response["results"]
            end
        end
      }
    end)
    data
  end

  def fetch_content(req, page_id, start_cursor) do
    Req.get!(req, url: "/blocks/#{page_id}/children?start_cursor=#{start_cursor}")
    |> case do
      %Req.Response{status: 200, body: response} ->
        if response["has_more"] do
          response["results"] ++ fetch_content(req, page_id, response["next_cursor"])
        else
          response["results"]
        end
    end
  end

  def elements(blocks) do
    Enum.reject(blocks, fn b -> b["archived"] end)
    |> Enum.map(&block_as_elements/1)
  end

  def block_as_elements(block) when is_list(block) do
    Enum.map(block, &block_as_elements/1)
  end

  def block_as_elements(block) when is_binary(block) do
    block
  end

  def block_as_elements(%{"type" => "paragraph"} = block) do
    {:p, block_as_elements(block["paragraph"]["rich_text"])}
  end

  def block_as_elements(%{"type" => "callout"} = block) do
    {:p, block_as_elements(block["callout"]["rich_text"])}
  end

  def block_as_elements(%{"type" => "text"} = block) do
    if is_nil(block["href"]) do
      {:s, block_as_elements(block["text"]["content"])}
    else
      {:s, {:a, block["href"], block["text"]["content"]}}
    end
  end

  def block_as_elements(%{"type" => "heading_1"} = block) do
    {:h1, block_as_elements(block["heading_1"]["rich_text"])}
  end

  def block_as_elements(%{"type" => "heading_2"} = block) do
    {:h2, block_as_elements(block["heading_2"]["rich_text"])}
  end

  def block_as_elements(%{"type" => "heading_3"} = block) do
    {:h3, block_as_elements(block["heading_3"]["rich_text"])}
  end

  def block_as_elements(%{"type" => "divider"}) do
    {:hr}
  end

  def block_as_elements(%{"type" => "image", "image" => %{"file" => %{"url" => url}}}) do
    {:image, url}
  end

end
