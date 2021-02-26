defmodule Onlinemaze.Domain.Character do
  use GenServer

  defstruct id: nil,
            o: nil,
            ghost: nil,
            v: %{x: 0, y: 0},
            x: 0,
            y: 0,
            random: nil,
            name: nil,
            room_name: nil,
            mode: "room"

  alias Onlinemaze.Domain.Calc

  @index 5
  @speed :math.pow(10, @index) |> round
  @map_in_size 199

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
       random: %{
         x: Enum.random(-@map_in_size..@map_in_size),
         y: Enum.random(-@map_in_size..@map_in_size)
       },
       name: name,
       room_name: room_name
     }}
  end

  def generate_id(room_name, name) do
    String.to_atom(room_name <> name)
  end

  def handle_cast({:change_mode, mode}, character) do
    {:noreply, character |> Map.replace!(:mode, mode)}
  end

  def handle_cast({:set_home_position, %{x: x, y: y}}, character) do
    {:noreply,
     character
     |> Map.replace!(:o, %{x: x * @speed, y: y * @speed})
     |> Map.replace!(:random, %{
       x: Enum.random(-@map_in_size..@map_in_size),
       y: Enum.random(-@map_in_size..@map_in_size)
     })}
  end

  def handle_cast(
        {:move_to, %{x: x, y: y}},
        character = %{
          random: random,
          room_name: room_name,
          ghost: ghost,
          o: o,
          x: bef_x,
          y: bef_y
        }
      ) do
    dx = trunc(@speed * x - o.x) + random.x
    dy = trunc(@speed * y - o.y) + random.y

    if(dx == bef_x and dy == bef_y) do
      {:noreply, character}
    else
      movement = {%{x: bef_x, y: bef_y}, %{x: dx, y: dy}}

      if Calc.crossing_wall?(room_name, movement) do
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

  def handle_call(:mode, _, character = %{mode: mode}) do
    {:reply, mode, character}
  end
end
