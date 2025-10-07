defmodule KddNotionEx.CMS.ExamplePage do
  use KddNotionEx.CMS.Model

  schema "Example Pages" do
    field :"Name", KddNotionEx.Types.Title
    field :"Number", :integer
    field :"Publish Date", KddNotionEx.Types.Date
    field :"Status", KddNotionEx.Types.Select
    field :"Description", KddNotionEx.Types.Text
  end

  def dummy() do
    %__MODULE__{
      "Name": "Post A",
      "Number": 1,
      "Publish Date": Date.utc_today(),
      "Status": "Approved",
      "Description": "Lorem ipsum..."
    }
  end

end
