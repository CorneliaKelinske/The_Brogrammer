defmodule TheBrogrammer.Blog do
  @moduledoc "The blog context"
  use Postex,
    # required
    prefix: "https://connie.codes/posts/",
    # default
    external_links_new_tab: true,
    # default
    per_page: 10
end
