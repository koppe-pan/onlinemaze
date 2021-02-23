defmodule Onlinemaze.Domain.GameSupervisor do
  @moduledoc """
  Game processes supervisor
  """
  require Logger
  import DynamicSupervisor, only: [start_child: 2, which_children: 1, terminate_child: 2]

  @server_mod Onlinemaze.DynamicGameServerSupervisor
  alias Onlinemaze.Domain.Room

  @doc """

  Creates a new supervised Game process
  """
  def create_game(attrs) do
    start_child(@server_mod, {Room, attrs})
  end

  def children() do
    @server_mod
    |> which_children()
  end

  def stop_game(pid) do
    terminate_child(@server_mod, pid)
  end
end
