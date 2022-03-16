defmodule TheBrogrammerWeb.Paginate do
  @moduledoc "Builds the pagination HTML for blog posts"
  use Phoenix.HTML

  alias TheBrogrammer.Blog
  alias TheBrogrammerWeb.Router.Helpers, as: Routes

  @doc "Builds the pagination selector with page numbers, next and back etc."
  @spec build(Plug.Conn.t(), pos_integer | String.t()) :: {:safe, iolist}
  def build(conn, page) when is_binary(page) do
    build(conn, String.to_integer(page))
  end

  def build(conn, page) do
    pages = Blog.pages()

    next_last = [
      paginate_button(conn, "Previous", page, pages),
      paginate_button(conn, "Next", page, pages)
    ]

    numbered_buttons =
      numbered_buttons(conn, page, pages)
      |> contag(:ul, class: "pagination-list")

    (next_last ++ numbered_buttons)
    |> contag(:nav, class: "pagination", "aria-label": "pagination")
  end

  # Handle the case where there is only a single page, just gives us some disabled buttons
  @spec numbered_buttons(Plug.Conn.t(), pos_integer, integer) :: [{:safe, iolist}]
  defp numbered_buttons(conn, _page, 0) do
    [paginate_button(conn, 1, 1, 1)]
  end

  defp numbered_buttons(conn, page, pages) do
    pages
    |> filter_pages(page)
    |> Enum.map(fn x -> paginate_button(conn, x, page, pages) end)
  end

  @spec paginate_button(Plug.Conn.t(), String.t() | integer, integer, integer) :: {:safe, iolist}
  defp paginate_button(_conn, "Next", page, pages) when page == pages do
    contag("Next", :a, class: "pagination-next is-right", disabled: true)
  end

  defp paginate_button(_conn, "Previous", 1, _pages) do
    contag("Previous", :a, class: "pagination-previous", disabled: true)
  end

  defp paginate_button(_conn, "....", _page, _pages) do
    contag("....", :a, class: "pagination-ellipsis")
    |> contag(:li, [])
  end

  defp paginate_button(conn, "Next", page, _pages) do
    link("Next",
      to: Routes.post_path(conn, :index, page + 1),
      class: "pagination-next is-right"
    )
  end

  defp paginate_button(conn, "Previous", page, _pages) do
    link("Previous",
      to: Routes.post_path(conn, :index, page - 1),
      class: "pagination-previous"
    )
  end

  defp paginate_button(_conn, same, same, _pages) do
    contag(same, :a, class: "pagination-link is-current")
    |> contag(:li, [])
  end

  defp paginate_button(conn, label, _page, _pages) do
    link(label,
      to: Routes.post_path(conn, :index, label),
      class: "pagination-link"
    )
    |> contag(:li, [])
  end

  @doc "Selects the page buttons we need for pagination"
  @spec filter_pages(integer, integer) :: [String.t() | Integer]
  def filter_pages(pages, _page) when pages <= 7, do: 1..pages

  def filter_pages(pages, page) when page in [1, 2, 3, pages - 2, pages - 1, pages] do
    [1, 2, 3, "....", pages - 2, pages - 1, pages]
  end

  def filter_pages(pages, page) do
    [1, "...."] ++ [page - 1, page, page + 1] ++ ["....", pages]
  end

  # Used everywhere to make it easier to pipe HTML chunks into each other
  @spec contag(any(), atom, keyword) :: {:safe, iolist}
  defp contag(body, tag, opts), do: content_tag(tag, body, opts)
end
