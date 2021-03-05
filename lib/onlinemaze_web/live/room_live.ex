defmodule OnlinemazeWeb.RoomLive do
  use OnlinemazeWeb, :live_view

  alias Onlinemaze.Usecases.{Character, Game}

  @impl true
  def mount(_params, %{"me" => me, "room_name" => name} = _session, socket) do
    {:ok,
     socket
     |> assign(room_name: name)
     |> assign(room_atom: String.to_atom(name))
     |> assign(characters: [])
     |> assign(me: me)
     |> assign(me_atom: Character.generate_id(name, me))
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
     |> assign(me_atom: nil)
     |> schedule_tick()}
  end

  @impl true
  def handle_event(
        "upload",
        %{"bytestring" => bytestring},
        socket = %{assigns: %{room_name: room_name}}
      ) do
    if Game.upload_maze(room_name, bytestring),
      do: {:noreply, socket |> put_flash(:info, "読み込みに成功しました")},
      else: {:noreply, socket |> put_flash(:error, "読み込みに失敗しました")}
  end

  @impl true
  def handle_event(
        "put-stream",
        _,
        socket = %{assigns: %{me_atom: nil}}
      ) do
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
       |> assign(me: Character.state(pid).name)
       |> assign(me_atom: Character.generate_id(room_name, name))}
    end
  end

  @impl true
  def handle_event(
        "set-location",
        %{"loc" => %{"x" => x, "y" => y}},
        socket = %{assigns: %{me_atom: me_atom}}
      ) do
    with :ok <-
           Character.set_home_position(me_atom, %{
             x: x,
             y: y
           }) do
      {:noreply, socket}
    end
  end

  def update_stream(socket = %{assigns: %{room_atom: room_atom}}) do
    case room_atom
         |> Game.list_character()
         |> Enum.reject(fn v -> is_nil(v) end) do
      [] ->
        socket

      stream ->
        socket
        |> push_event("pushStream", %{
          stream:
            stream
            |> Enum.map(fn v -> Character.stream(v) end)
            |> Enum.reduce(fn v, acc ->
              Enum.zip(v, acc)
              |> Enum.map(fn {a, b} -> a + b end)
            end)
        })
    end
  end

  def update(socket = %{assigns: %{room_atom: room_atom}}) do
    socket
    |> assign(:characters, Game.list_character_state(room_atom))
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
