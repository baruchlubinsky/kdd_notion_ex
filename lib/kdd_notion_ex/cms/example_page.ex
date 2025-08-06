defmodule KddNotionEx.CMS.ExamplePage do
  use KddNotionEx.CMS.Model

  schema "Example Pages" do
    field :"Name", KddNotionEx.Types.Title
    field :"Number", :integer
    field :"Publish Date", :naive_datetime
    field :"Status", KddNotionEx.Types.Select
    field :"Description", :string
  end

end
