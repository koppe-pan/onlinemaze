defmodule Onlinemaze.Domain.Character do
  use GenServer

  defstruct id: nil, o: nil, ghost: nil, v: nil, x: 0, y: 0, name: nil, room_name: nil
  alias Onlinemaze.Usecases.Game

  @index 5
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
       o: %{x: ox * @speed, y: oy * @speed},
       name: name,
       room_name: room_name
     }}
  end

  def generate_id(room_name, name) do
    String.to_atom(room_name <> name)
  end

  def handle_cast({:set_home_position, %{x: x, y: y}}, character) do
    {:noreply,
     character
     |> Map.replace!(:o, %{x: x * @speed, y: y * @speed})}
  end

  def handle_cast(
        {:move_to, %{x: x, y: y}},
        character = %{room_name: room_name, ghost: ghost, o: o, x: bef_x, y: bef_y}
      ) do
    dx = trunc(@speed * x - o.x)
    dy = trunc(@speed * y - o.y)

    if(dx == bef_x and dy == bef_y) do
      {:noreply, character}
    else
      position = {%{x: bef_x, y: bef_y}, %{x: dx, y: dy}}

      is_wall =
        Game.list_walls(String.to_atom("wall" <> room_name))
        |> Task.async_stream(fn v -> is_other_side(v, position) end)
        |> Enum.any?(fn {:ok, v} -> v end)

      if is_wall do
        if is_nil(ghost) do
          {:noreply,
           character
           |> Map.replace!(:ghost, %{x: dx, y: dy})
           |> Map.replace!(:v, %{x: dx - bef_x, y: dy - bef_y})}
        else
          {:noreply,
           character
           |> Map.replace!(:ghost, %{x: dx, y: dy})
           |> Map.replace!(:v, %{x: dx - ghost.x, y: dy - ghost.y})}
        end
      else
        {:noreply,
         character
         |> Map.replace!(:ghost, nil)
         |> Map.replace!(:x, dx)
         |> Map.replace!(:y, dy)
         |> Map.replace!(:v, %{x: dx - bef_x, y: dy - bef_y})}
      end
    end
  end

  def handle_call(:name_and_position, _, character = %{x: x, y: y, name: name}) do
    {:reply, %{x: x, y: y, name: name}, character}
  end

  def handle_call(:position, _, character = %{x: x, y: y}) do
    {:reply, %{x: x, y: y}, character}
  end

  def handle_call(:ghost_position, _, character = %{ghost: ghost}) do
    {:reply, ghost, character}
  end

  def handle_call(:velocity, _, character = %{v: v}) do
    {:reply, v, character}
  end

  def is_other_side(a, b) do
    calc(a, b) and calc(b, a)
  end

  defp calc({a, b}, {c, d}) do
    ((a.x - b.x) * (c.y - a.y) - (c.x - a.x) * (a.y - b.y)) *
      ((a.x - b.x) * (d.y - a.y) - (d.x - a.x) * (a.y - b.y)) < 0
  end
end
