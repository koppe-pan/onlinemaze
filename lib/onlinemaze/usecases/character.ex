defmodule Onlinemaze.Usecases.Character do
  alias Onlinemaze.Domain.{CharacterSupervisor, Room}

  def create_character(attrs = %{room_name: room_name}) do
    with {:ok, pid} <- CharacterSupervisor.create_character(attrs) do
      Process.register(pid, state(pid).id)
      Room.register(String.to_atom(room_name), state(pid).id)
      {:ok, pid}
    end
  end

  def check_name(supervisor, name) do
    Room.list(supervisor)
    |> Enum.any?(fn v -> state(v).id == name end)
  end

  def state(pid) do
    :sys.get_state(pid)
  end

  def me_position(me_atom) do
    GenServer.call(me_atom, :position)
  end

  def ghost_position(me_atom) do
    GenServer.call(me_atom, :ghost_position)
  end

  def me_velocity(me_atom) do
    GenServer.call(me_atom, :velocity)
  end

  def stream(me_atom) do
    GenServer.call(me_atom, :stream)
  end

  def mode(me_atom) do
    GenServer.call(me_atom, :mode)
  end

  def set_home_position(me_atom, attrs) do
    GenServer.cast(me_atom, {:set_home_position, attrs})
  end

  def move_to(me_atom, attrs) do
    GenServer.cast(me_atom, {:move_to, attrs})
  end

  def update_stream(me_atom, stream) do
    GenServer.cast(me_atom, {:update_stream, stream})
  end

  def change_mode(me_atom, mode) do
    GenServer.call(me_atom, {:change_mode, mode})
  end

  def generate_id(room_name, name) do
    Onlinemaze.Domain.Character.generate_id(room_name, name)
  end
end
