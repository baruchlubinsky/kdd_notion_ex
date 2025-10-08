defmodule KddNotionEx.DataSource do

  def get_properties(req, id) do
    Req.get!(req, url: "/data_sources/#{id}")
    |> KddNotionEx.Client.response("properties")
  end

  def query(req, data_source_id, query \\ %{}) do
    Req.post!(req, url: "/data_sources/#{data_source_id}/query", json: query)
    |> case do
      %Req.Response{status: 200, body: response} ->
        if response["has_more"] do
        query = Map.put(query, "start_cursor", response["next_cursor"])
        response["results"] ++ query_paged(req, data_source_id, query)
      else
        response["results"]
      end
    end
  end

  def query_paged(req, data_source_id, query) do
    Req.post!(req, url: "/data_sources/#{data_source_id}/query", json: query)
    |> case do
      %Req.Response{status: 200, body: response} ->
        if response["has_more"] do
        query = query || %{}
          |> Map.put("start_cursor", response["next_cursor"])
        response["results"] ++ query_paged(req, data_source_id, query)
      else
        response["results"]
      end
    end
  end

end
