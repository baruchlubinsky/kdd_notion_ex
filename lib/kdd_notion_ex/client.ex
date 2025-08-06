defmodule KddNotionEx.Client do
  def headers() do
    [
      {"Content-Type", "application/json"},
      {"Notion-Version", "2022-06-28"}
    ]
  end

  def new() do
    Req.new(base_url: "https://api.notion.com/v1", headers: headers())
  end

  def new(token) do
    new()
    |> authenticated(token)
  end

  def authenticated(req, token) do
    Req.Request.merge_options(req, auth: {:bearer, token})
  end

  def response(response) do
    case response do
      %Req.Response{status: 200, body: body} ->
        body
      %Req.Response{status: 400, body: body} ->
        throw body
    end
  end

  def response(response, field) do
    case response do
      %Req.Response{status: 200, body: body} ->
        body[field]
      %Req.Response{status: 400, body: body} ->
        throw body
    end
  end

end
