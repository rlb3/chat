// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket, Presence} from "phoenix"

let socket = new Socket("/socket", {params: {userId: window.userId}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let presences = {}
let channel = socket.channel("room:lobby", {})

let formatTimestamp = (timestamp) => {
    let date = new Date(timestamp*1000)
    return date.toLocaleTimeString()
}
let listBy = (user, {metas: metas}) => {
    return {
        user: user,
        onlineAt: formatTimestamp(metas[0].online_at)
    }
}

let userList = document.getElementById("users")
let user_render = (presences) => {
    userList.innerHTML = Presence.list(presences, listBy)
        .filter(presence => { return presence.user != "undefined" })
        .map(presence => `
          <li class="media">
            <div class="media-body">
              <div class="media">
                <a class="pull-left" href="#">
                  <!-- <img class="media-object img-circle" style="max-height:40px;" src="assets/img/user.png" /> -->
                </a>
                <div class="media-body" >
                  <h5>${presence.user}</h5>
                  <small class="text-muted">${presence.onlineAt}</small>
                </div>
              </div>
            </div>
          </li>
`).join("")
}

let messageList = document.getElementById("messages")
let message_render = (message) => {
    messageList.innerHTML = messageList.innerHTML + `
          <li class="media">
            <div class="media-body">
              <div class="media">
                <a class="pull-left" href="#">
                  <!-- <img class="media-object img-circle " src="assets/img/user.png" /> -->
                </a>
                <div class="media-body" >
                  ${message.body}
                  <br />
                  <small class="text-muted">${message.userId}</small>
                  <hr />
                </div>
              </div>
            </div>
          </li>
`
}

let onJoin = (id, current, newPres) => {
    if(!current){
        console.log("user has entered for the first time", id, newPres)
    } else {
        console.log("user additional presence", id, newPres)
    }
}
// detect if user has left from all tabs/devices, or is still present
let onLeave = (id, current, leftPres) => {
    if(current.metas.length === 0){
        console.log("user has left from all devices", id, leftPres)
    } else {
        console.log("user left from a device", id, leftpres)
    }
}

channel.on("presence_state", state => {
    presences = Presence.syncState(presences, state, onJoin, onLeave)
    user_render(presences)
})

channel.on("presence_diff", diff => {
    presences = Presence.syncDiff(presences, diff, onJoin, onLeave)
    user_render(presences)
})

channel.on("new_msg", payload => {
    message_render(payload)
})

$('button').click(function(e) {
    e.preventDefault();
    const message = $('input').val()
    const payload = {userId: window.userId, body: message}
    channel.push("new_msg", payload)
    message_render(payload)
    $('input').val("")
})


channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
