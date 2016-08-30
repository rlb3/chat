defmodule Chat.MessageController do
  use Chat.Web, :controller

  alias Chat.Message

  plug :username

  # def index(conn, _params) do
  #   messages = from(m in Message, limit: 5, order_by: [desc: :inserted_at]) |> Repo.all |> Enum.reverse
  #   username = get_session(conn, :username)
  #   render(conn, "index.html", messages: messages, username: username)
  # end

  def index(conn, _params) do
    messages = Message.recent
    |> Repo.all
    |> Enum.reverse
    render(conn, "index.html", messages: messages, username: conn.assigns.username)
  end

  defp username(conn, _opt) do
    conn
    |> assign(:username, get_session(conn, :username))
  end
end
