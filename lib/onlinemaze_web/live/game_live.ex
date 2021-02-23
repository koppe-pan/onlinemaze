defmodule OnlinemazeWeb.GameLive do
  use OnlinemazeWeb, :live_view

  alias Onlinemaze.Usecases.{Character}

  @impl true
  def mount(_params, %{"me" => me, "room_name" => room_name} = _session, socket) do
    me_atom = Character.generate_id(room_name, me)

    {:ok,
     socket
     |> assign(room_name: room_name)
     |> assign(room_atom: String.to_atom(room_name))
     |> assign(me_atom: me_atom)
     |> assign(me: %{x: 0, y: 0})
     |> assign(others: [])
     |> assign(time: 0)
     |> assign(width: 320)
     |> assign(height: 320)
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

  def update_time(socket = %{assigns: %{time: time}}) do
    socket
    |> assign(time: time + 1)
  end

  def update_me(socket = %{assigns: %{me_atom: me_atom}}) do
    socket
    |> assign(me: Character.me_position(me_atom))
  end

  def update_others(socket = %{assigns: %{room_atom: room_atom, me_atom: me_atom}}) do
    socket
    |> assign(others: Character.others_positions(room_atom, me_atom))
  end

  def update(socket) do
    socket
    |> update_time()
    |> update_me()
    |> update_others()
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply,
     socket
     |> update()
     |> schedule_tick()}
  end

  defp schedule_tick(socket) do
    Process.send_after(self(), :tick, 100)
    socket
  end
end
