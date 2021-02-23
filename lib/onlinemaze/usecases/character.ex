defmodule Onlinemaze.Usecases.Character do
  alias Onlinemaze.Domain.{CharacterSupervisor, Room}

  def create_character(attrs = %{room_name: room_name}) do
    with {:ok, pid} <- CharacterSupervisor.create_character(attrs) do
      Process.register(pid, state(pid).id)
      Room.register(String.to_atom(room_name), state(pid).id)
      {:ok, pid}
    end
  end

  def list(supervisor) do
    Room.list(supervisor)
  end

  def list_state(supervisor) do
    Room.list(supervisor)
    |> Enum.map(fn v -> state(v) end)
  end

  def check_name(supervisor, name) do
    Room.list(supervisor)
    |> Enum.any?(fn v -> state(v).id == name end)
  end

  def state(pid) do
    :sys.get_state(pid)
  end

  def move_to(me_atom, attrs) do
    GenServer.cast(me_atom, {:move_to, attrs})
  end

  def others_positions(room_atom, me_atom) do
    room_atom
    |> list()
    |> Enum.reject(fn v -> v == me_atom end)
    |> Enum.map(fn v -> GenServer.call(v, :position) end)
  end

  def me_position(me_atom) do
    GenServer.call(me_atom, :position)
  end

  def me_velocity(me_atom) do
    GenServer.call(me_atom, :velocity)
  end

  def generate_id(room_name, name) do
    Onlinemaze.Domain.Character.generate_id(room_name, name)
  end
end
