defmodule Onlinemaze.Domain.Wall do
  use GenServer

  def start_link(attrs) do
    GenServer.start_link(__MODULE__, attrs)
  end

  @map_size 200

  @initial [
    {%{x: -@map_size, y: -@map_size}, %{x: -@map_size, y: @map_size}},
    {%{x: -@map_size, y: -@map_size}, %{x: @map_size, y: -@map_size}},
    {%{x: -@map_size, y: @map_size}, %{x: @map_size, y: @map_size}},
    {%{x: @map_size, y: -@map_size}, %{x: @map_size, y: @map_size}}
  ]

  @impl true
  def init(_) do
    {:ok, @initial}
  end

  @impl true
  def handle_cast({:add, wall = {%{x: _, y: _}, %{x: _, y: _}}}, walls) do
    {:noreply, [wall | walls]}
  end

  @impl true
  def handle_cast({:add, {a, b, c, d}}, walls) do
    {:noreply, [{%{x: a, y: b}, %{x: c, y: d}} | walls]}
  end

  @impl true
  def handle_cast(:reset, walls) do
    {:noreply, @initial}
  end

  @impl true
  def handle_call(:list, _, walls) do
    {:reply, walls, walls}
  end

  def generate_id(name) do
    String.to_atom("wall" <> name)
  end
end
