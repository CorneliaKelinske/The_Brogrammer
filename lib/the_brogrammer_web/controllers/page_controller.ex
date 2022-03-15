defmodule TheBrogrammerWeb.PageController do
  use TheBrogrammerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
