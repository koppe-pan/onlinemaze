defmodule OnlinemazeWeb.RoomLive do
  use OnlinemazeWeb, :live_view

  alias Onlinemaze.Usecases.Character

  @impl true
  def mount(_params, %{"me" => me, "room_name" => name} = _session, socket) do
    me_atom = Character.generate_id(name, me)
    Character.change_mode(me_atom, "room")

    {:ok,
     socket
     |> assign(room_name: name)
     |> assign(room_atom: String.to_atom(name))
     |> assign(characters: [])
     |> assign(me: me)
     |> schedule_tick()}
  end

  @impl true
  def mount(_params, %{"room_name" => name} = _session, socket) do
    {:ok,
     socket
     |> assign(room_name: name)
     |> assign(room_atom: String.to_atom(name))
     |> assign(characters: [])
     |> assign(me: nil)
     |> schedule_tick()}
  end

  @impl true
  def handle_event("check-name", %{"name" => name}, socket = %{assigns: %{room_atom: room_atom}}) do
    if(Character.check_name(room_atom, name)) do
      {:noreply,
       socket
       |> put_flash("error", "既に存在する名前です。")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event(
        "set-location",
        %{"loc" => %{"x" => x, "y" => y}, "name" => name},
        socket = %{assigns: %{room_name: room_name}}
      ) do
    with {:ok, pid} <-
           Character.create_character(%{ox: x, oy: y, name: name, room_name: room_name}) do
      {:noreply,
       socket
       |> assign(me: Character.state(pid).name)}
    end
  end

  @impl true
  def handle_event(
        "set-location",
        %{"loc" => %{"x" => x, "y" => y}},
        socket = %{assigns: %{room_name: room_name, me: me}}
      ) do
    with :ok <-
           Character.set_home_position(Character.generate_id(room_name, me), %{
             x: x,
             y: y
           }) do
      {:noreply, socket}
    end
  end

  def update(socket = %{assigns: %{room_atom: room_atom}}) do
    socket
    |> assign(:characters, Character.list_state(room_atom))
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
