defmodule KddNotionEx.Database do

  def get_properties(req, database_id) do
    {_, data} = Cachex.fetch(KddNotionEx.Cache.properties(), database_id, fn id ->
      {
        :commit,
        Req.get!(req, url: "/databases/#{id}")
        |> KddNotionEx.Client.response("properties")
      }
    end)
    data
  end

  def query(req, database_id, query) do
    {_, data} = Cachex.fetch(KddNotionEx.Cache.queries(), {database_id, query}, fn _ ->
      {
        :commit,
        Req.post!(req, url: "/databases/#{database_id}/query", json: query)
        |> case do
          %Req.Response{status: 200, body: response} ->
            if response["has_more"] do
            query = query || %{}
              |> Map.put("start_cursor", response["next_cursor"])
            response["results"] ++ query_page(req, database_id, query)
          else
            response["results"]
          end
        end
      }
    end)
    data
  end

  def query_page(req, database_id, query) do
    Req.post!(req, url: "/databases/#{database_id}/query", json: query)
    |> case do
      %Req.Response{status: 200, body: response} ->
        if response["has_more"] do
        query = query || %{}
          |> Map.put("start_cursor", response["next_cursor"])
        response["results"] ++ query_page(req, database_id, query)
      else
        response["results"]
      end
    end
  end

end
