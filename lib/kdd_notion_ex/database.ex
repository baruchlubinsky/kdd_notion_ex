defmodule KddNotionEx.Database do

  def get_properties(req, database_id) do
    Req.get!(req, url: "/databases/#{database_id}")
    |> KddNotionEx.Client.response("properties")
  end

  def query(req, database_id, query) do
    Req.post!(req, url: "/databases/#{database_id}/query", json: query)
    |> case do
      %Req.Response{status: 200, body: response} ->
        if response["has_more"] do
        query = query || %{}
          |> Map.put("start_cursor", response["next_cursor"])
        response["results"] ++ query(req, database_id, query)
      else
        response["results"]
      end
    end
  end

end
