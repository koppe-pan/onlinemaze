defmodule Onlinemaze.Usecases.Game do
  alias Onlinemaze.Domain.{GameSupervisor, Room, Treasure, Wall}
  alias Onlinemaze.Usecases.Character

  def create_game(name) do
    with {:ok, pid} <- GameSupervisor.create_game(name) do
      with {:ok, wall_pid} <- Wall.start_link([]) do
        Process.register(wall_pid, Wall.generate_id(name))

        with {:ok, treasure_pid} <- Treasure.start_link([]) do
          Process.register(treasure_pid, Treasure.generate_id(name))
          {:ok, pid}
        end
      end
    end
  end

  def check_name(name) do
    GameSupervisor.children()
    |> Enum.any?(fn {_, v, _, _} -> state(v).id == name end)
  end

  def check_treasure_clear(room_name) do
    treasure_position = treasure_position(Treasure.generate_id(room_name))

    room_name
    |> String.to_atom()
    |> others_positions("", "game")
    |> Enum.all?(fn v ->
      Treasure.find_treasure?(v, treasure_position)
    end)
  end

  def check_treasure_clear(room_name, me_atom) do
    Treasure.find_treasure?(
      Character.me_position(me_atom),
      treasure_position(Treasure.generate_id(room_name))
    )
  end

  def state(pid) do
    :sys.get_state(pid)
  end

  def move_with(pid, vel) do
    GenServer.cast(pid, {:move_with, vel})
  end

  def position(pid) do
    GenServer.call(pid, :position)
  end

  def treasure_position(pid) do
    GenServer.call(pid, :position)
  end

  def add_wall(pid, wall) do
    GenServer.cast(pid, {:add, wall})
  end

  def reset_walls(pid) do
    GenServer.cast(pid, :reset)
  end

  def upload_maze(room_name, bytestring) do
    pid = Wall.generate_id(room_name)
    reset_walls(pid)

    bytestring
    |> String.split()
    |> Task.async_stream(fn v ->
      add_wall(
        pid,
        v
        |> String.split(",")
        |> Enum.map(fn v -> String.to_integer(v) end)
        |> List.to_tuple()
      )
    end)
    |> Enum.all?(fn {:ok, _} -> true end)
  end

  def list_walls(pid) do
    GenServer.call(pid, :list)
  end

  def list_character(supervisor) do
    Room.list(supervisor)
  end

  def list_character_state(supervisor) do
    Room.list(supervisor)
    |> Enum.map(fn v -> state(v) end)
  end

  def list_character_by_mode(room_atom, mode) do
    room_atom
    |> list_character()
    |> Enum.filter(fn v -> GenServer.call(v, :mode) == mode end)
  end

  def list_character_state_by_mode(room_atom, mode) do
    room_atom
    |> list_character()
    |> Enum.filter(fn v -> GenServer.call(v, :mode) == mode end)
    |> Enum.map(fn v -> state(v) end)
  end

  def others(room_atom, me_atom, mode) do
    room_atom
    |> list_character()
    |> Enum.reject(fn v -> v == me_atom end)
    |> Enum.filter(fn v -> GenServer.call(v, :mode) == mode end)
  end

  def others_positions(room_atom, me_atom, mode) do
    others(room_atom, me_atom, mode)
    |> Enum.map(fn v -> GenServer.call(v, :position) end)
  end

  def others_name_and_positions(room_atom, me_atom, mode) do
    others(room_atom, me_atom, mode)
    |> Enum.map(fn v -> GenServer.call(v, :name_and_position) end)
  end

  def others_name_and_positions_and_ghosts(room_atom, me_atom, mode) do
    others(room_atom, me_atom, mode)
    |> Enum.map(fn v -> GenServer.call(v, :name_and_position_and_ghost) end)
  end

  def check_mode_available(%{room_atom: room_atom, me_atom: me_atom, mode: mode}) do
    GenServer.call(room_atom, {:check_mode_available, %{me_atom: me_atom, mode: mode}})
  end
end
