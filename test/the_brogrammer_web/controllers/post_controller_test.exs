defmodule TheBrogrammerWeb.PostControllerTest do
  use TheBrogrammerWeb.ConnCase, async: true

  describe "show/2" do
    test "with valid post ID renders the post", %{conn: conn} do
      id = "hello_world"

      conn = get(conn, Routes.post_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Where to start?"
    end

    test "handles not found", %{conn: conn} do
      conn = get(conn, Routes.post_path(conn, :show, "bad-route"))
      assert html_response(conn, 200) =~ "Not Found"
    end
  end
end
