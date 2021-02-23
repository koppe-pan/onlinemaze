defmodule Onlinemaze.Usecases.Game do
  alias Onlinemaze.Domain.GameSupervisor

  def create_game(name) do
    GameSupervisor.create_game(name)
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
end
