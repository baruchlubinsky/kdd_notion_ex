defmodule KddNotionEx.CMS.Elements do
  def block_as_elements(block, opts \\ [])

  def block_as_elements(blocks, opts) when is_list(blocks) do
    Enum.map(blocks, fn block -> KddNotionEx.CMS.Elements.block_as_elements(block, opts) end)
  end

  def block_as_elements(block, _opts) when is_binary(block) do
    block
  end

  def block_as_elements(%{"type" => "paragraph"} = block, opts) do
    {:p, block_as_elements(block["paragraph"]["rich_text"], opts)}
  end

  def block_as_elements(%{"type" => "callout"} = block, opts) do
    {:cta, block_as_elements(block["callout"]["rich_text"], opts)}
  end

  def block_as_elements(%{"type" => "bulleted_list_item"} = block, opts) do
    {:li, block_as_elements(block["bulleted_list_item"]["rich_text"], opts)}
  end

  def block_as_elements(%{"type" => "text"} = block, opts) do
    if is_nil(block["href"]) do
      {:s, block_as_elements(block["text"]["content"], opts)}
    else
      f = Keyword.get(opts, :paths, fn v -> v end)
      link = f.(block["href"])
      {:s, {:a, link, block["text"]["content"]}}
    end
  end

  def block_as_elements(%{"type" => "heading_1"} = block, opts) do
    {:h1, block_as_elements(block["heading_1"]["rich_text"], opts)}
  end

  def block_as_elements(%{"type" => "heading_2"} = block, opts) do
    {:h2, block_as_elements(block["heading_2"]["rich_text"], opts)}
  end

  def block_as_elements(%{"type" => "heading_3"} = block, opts) do
    {:h3, block_as_elements(block["heading_3"]["rich_text"], opts)}
  end

  def block_as_elements(%{"type" => "divider"}, _opts) do
    {:hr}
  end

  def block_as_elements(%{"type" => "image", "id" => id, "image" => _image}, _opts) do
    {_, data} = Cachex.fetch(KddNotionEx.Cache.images(), id, fn _ ->
      image =
        KddNotionEx.Cache.images_client()
        |> KddNotionEx.Page.fetch_block(id)
      {
        :commit,
        case image do
          %{"image" => %{"caption" => alt, "file" => %{"url" => url, "expiry_time" => _expires}}} ->
            {:image, url, "#{alt}"}
          end,
        expire: :timer.seconds(3550) # Notion API returns links valid for 1 hour
    }
    end)
    data
  end

  def block_as_elements(%{"type" => "mention", "href" => notion_url, "mention" => %{"page" => %{"id" => page_id}}, "plain_text" => text}, opts) do
    href =
    if Keyword.has_key?(opts, :paths) do
      id = String.replace(page_id, "-", "")
      "/#{id}"
    else
      notion_url
    end
    block_as_elements(%{"type" => "text", "href" => href, "text" => %{"content" => text}}, opts)
  end



end
