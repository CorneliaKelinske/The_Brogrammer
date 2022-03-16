defmodule TheBrogrammerWeb.FallbackController do
  use TheBrogrammerWeb, :controller

  def call(conn, nil) do
    conn
    |> put_flash(:error, "Something went wrong")
    |> redirect(to: Routes.contact_path(conn, :new))
  end
end
