defmodule Onlinemaze.Usecases.Game do
  alias Onlinemaze.Domain.{GameSupervisor, Wall}

  def create_game(name) do
    with {:ok, pid} <- GameSupervisor.create_game(name) do
      with {:ok, wall_pid} <- Wall.start_link([]) do
        Process.register(wall_pid, Wall.generate_id(name))
        {:ok, pid}
      end
    end
  end

  def check_name(name) do
    GameSupervisor.children()
    |> Enum.any?(fn {_, v, _, _} -> state(v).id == name end)
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

  def add_wall(pid, wall) do
    GenServer.cast(pid, {:add, wall})
  end

  def list_walls(pid) do
    GenServer.call(pid, :list)
  end
end
