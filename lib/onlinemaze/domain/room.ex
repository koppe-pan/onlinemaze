defmodule Onlinemaze.Domain.Room do
  use GenServer
  alias Onlinemaze.Domain.Character

  defstruct id: nil,
            characters: [],
            x: 0,
            y: 0

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
     |> Map.replace!(:characters, [name | characters])}
  end

  @impl true
  def handle_cast({:move_with, %{x: vx, y: vy}}, room = %{x: x, y: y}) do
    {:noreply,
     room
     |> Map.replace!(:x, x + vx)
     |> Map.replace!(:y, y + vy)}
  end

  @impl true
  def handle_call(:position, _, room = %{x: x, y: y}) do
    {:reply, %{x: x, y: y}, room}
  end

  @impl true
  def handle_call(:list, _, room = %{characters: characters}) do
    {:reply, characters, room}
  end
end
