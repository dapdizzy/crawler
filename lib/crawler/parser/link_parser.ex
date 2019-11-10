defmodule Crawler.Parser.LinkParser do
  @moduledoc """
  Parses links and transforms them if necessary.
  """

  alias __MODULE__.LinkExpander

  @tag_attr %{
    "a"      => "href",
    "link"   => "href",
    "script" => "src",
    "img"    => "src",
  }

  @doc """
  Parses links and transforms them if necessary.

  ## Examples

      iex> LinkParser.parse(
      iex>   {"a", [{"hello", "world"}, {"href", "http://hello.world"}], []},
      iex>   %{},
      iex>   &Kernel.inspect(&1, Enum.into(&2, []))
      iex> )
      "{\\\"href\\\", \\\"http://hello.world\\\"}"

      iex> LinkParser.parse(
      iex>   {"img", [{"hello", "world"}, {"src", "http://hello.world"}], []},
      iex>   %{},
      iex>   &Kernel.inspect(&1, Enum.into(&2, []))
      iex> )
      "{\\\"src\\\", \\\"http://hello.world\\\"}"
  """
  def parse({tag, attrs, html}, opts, link_handler, link_collector \\ nil) do
    src = @tag_attr[tag]

    with {_tag, link} <- detect_link(src, attrs),
         element      <- LinkExpander.expand({src, link}, opts)
    do
      opts = Map.merge(opts, %{html_tag: tag})

      if link_collector, do: link_collector.(element |> get_url, html |> get_text)

      link_handler.(element, opts)
    end
  end

  defp get_url(element)

  defp get_url({_, _link, _, url}), do: url
  defp get_url({_, url}), do: url

  defp get_text(html)

  defp get_text(html), do: Floki.text(html)

  defp detect_link(src, attrs) do
    Enum.find(attrs, fn(attr) ->
      Kernel.match?({^src, _link}, attr)
    end)
  end
end
