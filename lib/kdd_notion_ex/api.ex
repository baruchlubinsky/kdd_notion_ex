defmodule KddNotionEx.Api do

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

  def ps() do
    KddNotionEx.Finch
  end

end
