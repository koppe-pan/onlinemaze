defmodule OnlinemazeWeb.TreasureLive do
  use OnlinemazeWeb, :live_view

  alias Onlinemaze.Usecases.{Character, Game}

  @impl true
  def mount(_params, %{"me" => me, "room_name" => room_name} = _session, socket) do
    me_atom = Character.generate_id(room_name, me)

    {:ok,
     socket
     |> assign(room_name: room_name)
     |> assign(room_atom: String.to_atom(room_name))
     |> assign(name: me)
     |> assign(me_atom: me_atom)
     |> assign(others: [])
     |> assign(width: 320)
     |> assign(height: 320)
     |> assign(mousestart: nil)
     |> assign(mouseend: nil)
     |> assign(wall_atom: String.to_atom("wall" <> room_name))
     |> assign(walls: [])
     |> assign(treasure: Game.treasure_position(String.to_atom("treasure" <> room_name)))
     |> schedule_tick()}
  end

  @impl true
  def handle_event("set-window", %{"win" => %{"x" => x, "y" => y}}, socket) do
    {:noreply, socket |> assign(width: div(x, 2)) |> assign(height: div(y, 2))}
  end

  @impl true
  def handle_event(
        "touchstart",
        %{"x" => x, "y" => y},
        socket
      ) do
    {:noreply,
     socket
     |> assign(mousestart: %{x: x, y: y})
     |> assign(mouseend: %{x: x, y: y})}
  end

  @impl true
  def handle_event(
        "touchmove",
        %{"x" => x, "y" => y},
        socket
      ) do
    {:noreply,
     socket
     |> assign(mouseend: %{x: x, y: y})}
  end

  @impl true
  def handle_event(
        "touchend",
        _,
        socket = %{
          assigns: %{
            wall_atom: wall_atom,
            mousestart: %{x: sx, y: sy},
            mouseend: %{x: ex, y: ey},
            width: w,
            height: h
          }
        }
      ) do
    Game.add_wall(wall_atom, {%{x: sx - w, y: sy - h}, %{x: ex - w, y: ey - h}})

    {:noreply,
     socket
     |> assign(mousestart: nil)
     |> assign(mouseend: nil)}
  end

  @impl true
  def handle_event("touchend", _, socket) do
    {:noreply,
     socket
     |> assign(mousestart: nil)
     |> assign(mouseend: nil)}
  end

  def update_others(socket = %{assigns: %{room_atom: room_atom, me_atom: me_atom}}) do
    socket
    |> assign(others: Character.others_name_and_positions_and_ghosts(room_atom, me_atom, "game"))
  end

  def update_walls(socket = %{assigns: %{wall_atom: wall_atom}}) do
    socket
    |> assign(walls: Game.list_walls(wall_atom))
  end

  def check_finish(socket = %{assigns: %{room_name: room_name}}) do
    if Game.check_treasure_clear(room_name),
      do: socket |> put_flash(:info, "ゲームクリア"),
      else: socket |> put_flash(:info, "壁を書いて宝まで導け")
  end

  def update(socket) do
    socket
    |> update_others()
    |> update_walls()
    |> check_finish()
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
