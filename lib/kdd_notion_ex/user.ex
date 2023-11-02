defmodule KddNotionEx.User do
  import KddNotionEx.Api

  def me(token) do
    Finch.build(:get, "https://api.notion.com/v1/users/me", headers(token))
    |> request!()
    |> case do
      %Finch.Response{status: 200, body: body} ->
        Jason.decode!(body)
      err ->
        IO.inspect(err)
    end
  end

end
