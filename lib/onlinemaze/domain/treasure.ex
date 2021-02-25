defmodule Onlinemaze.Domain.Treasure do
  use GenServer

  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  @map_in_size 199
  @treasure_size 10

  @impl true
  def init(_) do
    {:ok,
     %{x: Enum.random(-@map_in_size..@map_in_size), y: Enum.random(-@map_in_size..@map_in_size)}}
  end

  @impl true
  def handle_call(:position, _, treasure) do
    {:reply, treasure, treasure}
  end

  def find_treasure?(position, treasure) do
    abs(position.x + position.y - treasure.x - treasure.y) <= @treasure_size
  end

  def generate_id(name) do
    String.to_atom("treasure" <> name)
  end
end
