defmodule OnlinemazeWeb.SpyLive do
  use OnlinemazeWeb, :live_view

  alias Onlinemaze.Usecases.{Character, Game}

  @impl true
  def mount(_params, %{"me" => me, "room_name" => room_name} = _session, socket) do
    {:ok,
     socket
     |> assign(room_name: room_name)
     |> assign(room_atom: String.to_atom(room_name))
     |> assign(me_atom: Character.generate_id(room_name, me))
     |> assign(me: %{x: 0, y: 0})
     |> assign(ghost: nil)
     |> assign(name: me)
     |> assign(others: [])
     |> assign(time: 0)
     |> assign(width: 320)
     |> assign(height: 320)
     |> assign(walls: Game.list_walls(String.to_atom("wall" <> room_name)))
     |> push_event("set-audio-media", %{})
     |> schedule_tick()}
  end

  @impl true
  def handle_event("set-window", %{"win" => %{"x" => x, "y" => y}}, socket) do
    {:noreply, socket |> assign(width: div(x, 2)) |> assign(height: div(y, 2))}
  end

  @impl true
  def handle_event(
        "put-location",
        %{"loc" => %{"x" => x, "y" => y}},
        socket = %{assigns: %{me_atom: me_atom}}
      ) do
    Character.move_to(me_atom, %{x: x, y: y})
    {:noreply, socket}
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

  def update_time(socket = %{assigns: %{time: time}}) do
    socket
    |> assign(time: time + 1)
  end

  def update_me(socket = %{assigns: %{me_atom: me_atom}}) do
    socket
    |> assign(me: Character.me_position(me_atom))
    |> assign(ghost: Character.ghost_position(me_atom))
  end

  def update_others(socket = %{assigns: %{room_atom: room_atom, me_atom: me_atom}}) do
    socket
    |> assign(others: Game.others_name_and_positions(room_atom, me_atom, "game"))
  end

  def check_finish(socket = %{assigns: %{room_name: room_name, me_atom: me_atom}}) do
    if Game.check_treasure_clear(room_name) do
      socket |> put_flash(:info, "ゲームクリア")
    else
      if Game.check_treasure_clear(room_name, me_atom),
        do: socket |> put_flash(:info, "発見しました！"),
        else: socket |> put_flash(:info, "壁をもとに宝を探せ")
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
    |> update_time()
    |> update_me()
    |> update_others()
    |> check_finish()
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
