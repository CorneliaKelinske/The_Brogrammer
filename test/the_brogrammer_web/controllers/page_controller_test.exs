defmodule TheBrogrammerWeb.PageControllerTest do
  use TheBrogrammerWeb.ConnCase

  test "index", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome"
  end

  test "home", %{conn: conn} do
    conn = get(conn, "/home")
    assert html_response(conn, 200) =~ "Welcome"
  end

  test "about", %{conn: conn} do
    conn = get(conn, "/about")
    assert html_response(conn, 200) =~ "Who is this bro-gramming person anyway?"
  end

  test "blog", %{conn: conn} do
    conn = get(conn, "/blog")
    assert html_response(conn, 200) =~ "Blog"
  end

  test "contact", %{conn: conn} do
    conn = get(conn, "/contact")
    assert html_response(conn, 200) =~ "Contact me"
  end
end
