defmodule Onlinemaze.Usecases.Game do
  alias Onlinemaze.Domain.{GameSupervisor, Treasure, Wall}
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
    |> Character.others_positions("", "game")
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

  def list_walls(pid) do
    GenServer.call(pid, :list)
  end
end
