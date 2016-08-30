defmodule Chat.RoomChannel do
  use Chat.Web, :channel
  alias Chat.Presence
  alias Chat.Message
  require Logger

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send self(), :after_join
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("new_msg", payload, socket) do
    broadcast_from socket, "new_msg", payload
    send self(), {:store_payload, payload}
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{online_at: inspect(System.system_time(:seconds))})
    push socket, "presence_state", Presence.list(socket)
    {:noreply, socket}
  end

  def handle_info({:store_payload, payload}, socket) do
    chset = Message.changeset(%Message{}, %{username: payload["userId"], body: payload["body"], channel: socket.topic})
    case Repo.insert(chset) do
      {:ok, _} ->
        {:noreply, socket}
      {:error, _} ->
        Logger.info ~s(Unable to save message: #{payload["userId"]}, #{payload["body"]}, #{socket.topic})
        {:noreply, socket}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
