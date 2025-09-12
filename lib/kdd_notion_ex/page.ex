defmodule KddNotionEx.Page do

  def get(req, page_id) do
    Req.get!(req, url: "/pages/#{page_id}")
  end

  def fetch(req, page_id) do
    {_, data} = Cachex.fetch(KddNotionEx.Cache.pages(), page_id, fn id ->
      page =
        get(req, id)
        |> KddNotionEx.Client.response()

      if Enum.any?(page["properties"], fn {_name, property} ->
        property["type"] == "files" && Enum.any?(property["files"], fn p -> Map.has_key?(p["file"], "expiry_time") end)
      end) do
        {
          :commit,
          page,
          expire: :timer.seconds(3550) # Notion API returns links valid for 1 hour (expire 10 seconds early)
        }
      else
        {
          :commit,
          page
        }
      end
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

  def fetch_block(req, block_id) do
    Req.get!(req, url: "/blocks/#{block_id}")
    |> case do
      %Req.Response{status: 200, body: response} ->
        response
    end
  end

  def elements(blocks, opts \\ []) do
    Enum.reject(blocks, fn b -> b["archived"] end)
    |> Enum.map(fn block -> KddNotionEx.CMS.Elements.block_as_elements(block, opts) end)
  end



end
