defmodule OnlinemazeWeb.LobbyForSpyLive do
  use OnlinemazeWeb, :live_view

  alias Onlinemaze.Usecases.{Character, Game}

  @impl true
  def mount(_params, %{"me" => me, "room_name" => room_name} = _session, socket) do
    {:ok,
     socket
     |> assign(room_name: room_name)
     |> assign(room_atom: String.to_atom(room_name))
     |> assign(me_atom: Character.generate_id(room_name, me))
     |> assign(name: me)
     |> assign(characters: [])
     |> assign(prepared: false)
     |> push_event("set-audio-media", %{})
     |> schedule_tick()}
  end

  @impl true
  def handle_event(
        "put-stream",
        %{"stream" => stream},
        socket = %{assigns: %{me_atom: me_atom}}
      ) do
    Character.update_stream(me_atom, stream)

    {:noreply, socket}
  end

  def update_me(socket = %{assigns: %{me_atom: me_atom}}) do
    socket
  end

  def update_others(socket = %{assigns: %{room_atom: room_atom, me_atom: me_atom}}) do
    socket
    |> assign(characters: Game.list_character_state_by_mode(room_atom, "lobby_for_spy"))
  end

  def check_game_state(
        socket = %{
          assigns: %{me_atom: me_atom, room_atom: room_atom, prepared: false}
        }
      ) do
    if Game.check_mode_available(%{me_atom: me_atom, room_atom: room_atom, mode: "lobby_for_spy"}) do
      socket |> put_flash(:info, "４人集まるまでお待ちください")
    else
      socket |> clear_flash() |> assign(prepared: true)
    end
  end

  def check_game_state(
        socket = %{
          assigns: %{
            me_atom: me_atom,
            room_atom: room_atom,
            room_name: room_name,
            name: me,
            prepared: true
          }
        }
      ) do
    if Game.check_mode_available(%{me_atom: me_atom, room_atom: room_atom, mode: "spy"}) do
      socket |> put_flash(:info, "４人全員の準備ができるまでお待ちください")
    else
      socket
      |> redirect(
        to:
          Routes.page_path(OnlinemazeWeb.Endpoint, :redirect_to_spy, me: me, room_name: room_name)
      )
    end
  end

  def update_stream(socket = %{assigns: %{me_atom: me_atom}}) do
    if is_nil(Character.stream(me_atom)),
      do: socket,
      else:
        socket
        |> push_event("pushStream", %{stream: Character.stream(me_atom)})
  end

  def update(socket) do
    socket
    |> update_me()
    |> update_others()
    |> check_game_state()
    |> update_stream()
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> update()
     |> schedule_tick()}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 10)
    socket
  end
end
