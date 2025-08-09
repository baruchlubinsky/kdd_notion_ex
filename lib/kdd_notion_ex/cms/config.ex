defmodule KddNotionEx.CMS.Config do
  use KddNotionEx.CMS.Model

  schema "CMS Settings" do
    field :"Page", KddNotionEx.Types.Title
    field :"Page URL", KddNotionEx.Types.URL
    field :"Published", KddNotionEx.Types.Checkbox
  end


end
