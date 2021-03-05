defmodule Onlinemaze.Domain.Room do
  use GenServer
  alias Onlinemaze.Domain.{Calc, Character, Mode}

  defstruct id: nil,
            characters: [],
            coop: %{x: 0, y: 0},
            ghost: nil

  def start_link(id) do
    with {:ok, pid} <- GenServer.start_link(__MODULE__, id) do
      Process.register(pid, String.to_atom(id))
      {:ok, pid}
    end
  end

  @impl true
  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end

  def register(pid, name) do
    GenServer.cast(pid, {:register, name})
  end

  def list(pid) do
    GenServer.call(pid, :list)
  end

  @impl true
  def handle_cast({:register, name}, room = %{characters: characters}) do
    {:noreply,
     room
     |> Map.replace!(:characters, [name | characters] |> Enum.uniq())}
  end

  @impl true
  def handle_cast({:move_with, %{x: vx, y: vy}}, room = %{id: id, coop: coop}) do
    to = %{x: coop.x + vx, y: coop.y + vy}

    if(to.x == coop.x and to.y == coop.y) do
      {:noreply, room}
    else
      movement = {coop, to}

      if Calc.crossing_wall?(id, movement) do
        {:noreply, room |> Map.replace!(:ghost, to)}
      else
        {:noreply,
         room
         |> Map.replace!(:ghost, nil)
         |> Map.replace!(:coop, to)}
      end
    end
  end

  @impl true
  def handle_call(
        {:check_mode_available, %{me_atom: me_atom, mode: mode}},
        _,
        room = %{characters: characters}
      ) do
    {:reply, Mode.check(characters |> Enum.reject(fn v -> v == me_atom end), mode), room}
  end

  @impl true
  def handle_call(:position, _, room = %{coop: coop}) do
    {:reply, coop, room}
  end

  @impl true
  def handle_call(:list, _, room = %{characters: characters}) do
    {:reply, characters, room}
  end
end
