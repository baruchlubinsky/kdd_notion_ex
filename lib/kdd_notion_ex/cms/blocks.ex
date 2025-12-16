defmodule KddNotionEx.CMS.Blocks do
  def new_page(title_key, title_value) do
    %{title_key => %{type: "title", title: [%{type: "text", text: %{ content: title_value } }] }}
  end


end
