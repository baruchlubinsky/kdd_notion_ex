defmodule KddNotionEx.Dev do

  def whoami(token) do
    KddNotionEx.Client.new(token)
    |> Req.get!(url: "/users/me")
  end

end
