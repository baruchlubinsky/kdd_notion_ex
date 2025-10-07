defmodule KddNotionEx.CMS.Properties do
  import KddNotionEx.Templates

  def serialize(type, key, value)

  def serialize(KddNotionEx.Types.Text, key, value) do
    text_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Date, key, value) do
    date_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Phone, key, value) do
    phone_number_prop(key, value)
  end

  # def serialize(KddNotionEx.Types.Formula, key, value)
  def serialize(KddNotionEx.Types.Title, key, value) do
    title_prop(key, value)
  end

  def serialize(KddNotionEx.Types.Select, key, value) do
    select_prop(key, value)
  end

  def serialize(KddNotionEx.Types.URL, key, value) do
    url_prop(key, value)
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


end
