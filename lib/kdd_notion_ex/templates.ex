defmodule KddNotionEx.Templates do

  def new_page(title_key, title_value) do
    title_prop(title_key, title_value)
  end

  def title_prop(key, value) do
    %{key => %{
      type: "title",
      title: [%{type: "text", text: %{ content: value } }]
      }
    }
  end

  def add_property(page, property) do
    Map.merge(page, property)
  end

  def text_prop(key, value) do
    %{
      key => %{
        rich_text: [
          %{
            type: "text",
            text: %{
              content: value
            }
          }
        ]
      }
    }
  end

  def select_prop(key, value) do
    %{
      key => %{
        select: %{
          name: value
        }
      }
    }
  end

  def multi_select_prop(key, values) do
    %{
      key => %{
        multi_select: Enum.map(values, fn value ->
          %{
            name: value
          }
        end)
      }
    }
  end

  def url_prop(key, value) do
    %{
      key =>
        %{
          type: "url", 
          url: value
        }
    }
  end

  def email_prop(key, value) do
    %{
      key =>
        %{
          type: "email", 
          email: value
        }
    }
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

  def phone_number_prop(key, value) do
    %{
      key => %{
        type: "phone_number",
        phone_number: value
      }
    }
  end

  def date_prop(key, value) when is_binary(value) do
    %{
      key => %{
        type: "date",
        date: %{
          start: value
        }
      }
    }
  end

  def date_prop(key, value) do
    %{
      key => %{
        type: "date",
        date: %{
          start: DateTime.to_iso8601(value)
        }
      }
    }
  end

  def date_range_prop(key, start_value, end_value) when is_binary(start_value) and is_binary(end_value) do
    %{
      key => %{
        type: "date",
        date: %{
          start: start_value,
          end: end_value
        }
      }
    }
  end

  def date_range_prop(key, start_value, end_value) do
    %{
      key => %{
        type: "date",
        date: %{
          start: DateTime.to_iso8601(start_value),
          end: DateTime.to_iso8601(end_value)
        }
      }
    }
  end

  def datestamp(key) do
    date_prop(key, Date.utc_today())
  end

  def timestamp(key) do
    date_prop(key, DateTime.utc_now())
  end

  def relation_prop(key, database, value) do
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

  def relation_prop(key, value) do
    %{
      key => %{
        type: "relation",
        relation: [%{
          id: value
        }]
      }
    }
  end

  def checkbox_prop(key, value) when value in [true, false] do
    %{
      key => %{
        checkbox: value
      }
    }
  end
end
