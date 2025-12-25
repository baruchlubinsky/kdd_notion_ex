defmodule KddNotionEx.Types.Date do
  use KddNotionEx.NotionType, ecto_type: :utc_datetime

  
  def cast(param) do
    case KddNotionEx.Transform.parse_property(param) do
      {start_time, _} -> {:ok, start_time}
      %{"date" => nil} -> {:ok, nil}
      date -> {:ok, date}
    end 
  end
  
end
