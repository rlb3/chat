defmodule Chat.PageController do
  use Chat.Web, :controller

  plug :set_session_username when action in [:create]

  def new(conn, _params) do
    render conn, "new.html", username: ""
  end

  # def create(conn, %{"pages" => %{"username" => username}}) do
  #   conn
  #   |> put_session(:username, username)
  #   |> redirect(to: message_path(conn, :index))
  # end

  def create(conn, _params) do
    redirect(conn, to: message_path(conn, :index))
  end


  defp set_session_username(conn, _opt) do
    case conn.params["pages"]["username"] do
      "" ->
        conn
        |> put_flash(:error, "You must choose an username")
        |> redirect(to: page_path(conn, :new))
      username ->
        conn
        |> put_session(:username, username)
    end
  end
end
