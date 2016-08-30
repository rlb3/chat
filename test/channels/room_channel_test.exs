defmodule Chat.RoomChannelTest do
  use Chat.ChannelCase

  alias Chat.RoomChannel

  setup do
    {:ok, _, socket} =
      socket(:user_id, %{user_id: "asdf"})
      |> subscribe_and_join(RoomChannel, "room:lobby")

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "shout broadcasts to room:lobby", %{socket: socket} do
    push socket, "new_msg", %{"hello" => "all"}
    assert_broadcast "new_msg", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
