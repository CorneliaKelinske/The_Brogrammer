defmodule TheBrogrammerWeb.PostView do
  use TheBrogrammerWeb, :view

  alias TheBrogrammerWeb.Paginate

  defdelegate paginate(conn, page), to: Paginate, as: :build
end
