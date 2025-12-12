defmodule KddNotionEx.CMS.Properties do
  import KddNotionEx.Templates

  def serialize(type, key, value)

  def serialize(:binary_id, key, value) do
    key = String.replace_suffix("#{key}", "_id", "")
    relation_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Text, key, value) do
    text_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Number, key, value) do
    number_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Date, key, value) do
    date_prop(key, value)
  end

  def serialize(KddNotionEx.Types.DateRange, key, {start_value, end_value}) do
    date_range_prop(key, start_value, end_value)
  end

  def serialize(KddNotionEx.Types.Phone, key, value) do
    phone_number_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Title, key, value) do
    title_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Select, key, value) do
    select_prop(key, value)
  end

  def serialize(KddNotionEx.Types.URL, key, value) do
    url_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Email, key, value) do
    email_prop(key, value)
  end

  def serialize(KddNotionEx.Types.MultiSelect, key, value) do
    multi_select_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Checkbox, key, value) do
    checkbox_prop(key, value)
  end

  def serialize(number, key, value) when number in [:integer, :float, :decimal] do
    number_prop(key, value)
  end

  def serialize(KddNotionEx.Types.UnqiueID, _key, _value) do
    %{} # Don't send Unique ID's
  end



end
