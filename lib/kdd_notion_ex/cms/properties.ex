defmodule KddNotionEx.CMS.Properties do

  def add_property(page, property) do
    Map.merge(page, property)
  end

  def number_prop(key, value) when is_binary(value) do
    number =
    if String.contains?(value, ".") do
      String.to_float(value)
    else
      String.to_integer(value)
    end

    number_prop(key, number)
  end

  def number_prop(key, value) do
    %{
      key => %{
        type: "number",
        number: value
      }
    }
  end

  def phone_number(key, value) do
    %{
      key => %{
        type: "phone_number",
        phone_number: value
      }
    }
  end

  def datestamp(key) do
    date(key, Date.to_iso8601(Date.utc_today))
  end

  def timestamp(key) do
    date(key, NaiveDateTime.to_iso8601(NaiveDateTime.utc_now))
  end

  def date(key, value) do
    %{
      key => %{
        type: "date",
        date: %{
          start: value
        }
      }
    }
  end

  def date(key, sv, ev) do
    %{
      key => %{
        type: "date",
        date: %{
          start: sv,
          end: ev
        }
      }
    }
  end

  def relation(key, database, value) do
    %{
      key => %{
        type: "relation",
        relation: [%{
          id: value,
          database_id: database
        }]
      }
    }
  end

  def relation(key, value) do
    %{
      key => %{
        type: "relation",
        relation: [%{
          id: value
        }]
      }
    }
  end

  def checkbox(key, value) when value in [true, false] do
    %{
      key => %{
        checkbox: value
      }
    }
  end
end
