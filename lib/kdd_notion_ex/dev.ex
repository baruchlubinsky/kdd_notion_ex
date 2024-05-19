defmodule KddNotionEx.Dev do
  import KddNotionEx.Api

  def whoami(token) do
    Finch.build(:get, "https://api.notion.com/v1/users/me", headers(token))
    |> request!()
  end

end
