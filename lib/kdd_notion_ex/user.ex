defmodule KddNotionEx.User do

  def me(token) do
    KddNotionEx.Client.new(token)
    |> Req.get!("/users/me")
    |> case do
      %Req.Response{status: 200, body: body} ->
        body
      err ->
        IO.inspect(err)
    end
  end

end
