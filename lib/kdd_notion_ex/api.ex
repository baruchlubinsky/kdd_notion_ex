defmodule KddNotionEx.Api do

  def headers() do
    [
      {"Content-Type", "application/json"},
      {"Notion-Version", "2022-06-28"}
    ]
  end

  def new() do
    Req.new(base_url: "https://api.notion.com/v1", headers: headers())
    #|> Req.Request.append_response_steps(decode: &decode/1)
  end

  def authenticated(req, token) do
    Req.Request.merge_options(req, auth: {:bearer, token})
  end

  def decode({request, response}) do
    case Req.Response.get_header(response, "content-type") do
      ["application/json" <> _] ->
        {request, update_in(response.body, &Jason.decode!/1)}

      [] ->
        {request, response}
    end
  end

  ### old:

  def headers(token) do
    [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"},
      {"Notion-Version", "2022-06-28"}
    ]
  end

  def request(payload) do
    Finch.request(payload, ps())
  end


  def request!(payload) do
    Finch.request!(payload, ps())
  end

  def read_body(response) do
    case response do
      %Finch.Response{status: 200, body: body} ->
        Jason.decode!(body)
    end
  end

  def ps() do
    KddNotionEx.Finch
  end

end
