defmodule Onlinemaze.Domain.Character do
  use GenServer

  defstruct id: nil, ox: 0, oy: 0, vx: 0, vy: 0, x: 0, y: 0, name: nil

  @index 6
  @speed :math.pow(10, @index) |> round

  @doc """
  Receive CharacterSupervisor
  """
  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  @impl true
  def init(%{ox: ox, oy: oy, name: name, room_name: room_name}) do
    {:ok,
     %__MODULE__{
       id: generate_id(room_name, name),
       ox: ox * @speed,
       oy: oy * @speed,
       name: name
     }}
  end

  def generate_id(room_name, name) do
    String.to_atom(room_name <> name)
  end

  def handle_cast({:set_home_position, %{x: x, y: y}}, character) do
    {:noreply,
     character
     |> Map.replace!(:ox, x)
     |> Map.replace!(:oy, y)}
  end

  def handle_cast({:move_to, %{x: x, y: y}}, character = %{ox: ox, oy: oy, x: bef_x, y: bef_y}) do
    dx = trunc(@speed * x - ox)
    dy = trunc(@speed * y - oy)

    {:noreply,
     character
     |> Map.replace!(:x, dx)
     |> Map.replace!(:y, dy)
     |> Map.replace!(:vx, dx - bef_x)
     |> Map.replace!(:vy, dy - bef_y)}
  end

  def handle_call(:name_and_position, _, character = %{x: x, y: y, name: name}) do
    {:reply, %{x: x, y: y, name: name}, character}
  end

  def handle_call(:position, _, character = %{x: x, y: y}) do
    {:reply, %{x: x, y: y}, character}
  end

  def handle_call(:velocity, _, character = %{vx: x, vy: y}) do
    {:reply, %{x: x, y: y}, character}
  end
end
