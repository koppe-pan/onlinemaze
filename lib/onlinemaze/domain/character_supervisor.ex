defmodule Onlinemaze.Domain.CharacterSupervisor do
  @moduledoc """
  Game processes supervisor
  """
  require Logger
  import DynamicSupervisor, only: [start_child: 2, which_children: 1, terminate_child: 2]
  use GenServer
  alias Onlinemaze.Domain.Character

  @server_mod Onlinemaze.DynamicCharacterServerSupervisor

  @doc """
  Creates a new supervised Game process
  """
  def create_character(id) do
    start_child(
      @server_mod,
      {Character, id}
    )
  end

  def children() do
    @server_mod
    |> which_children()
  end

  def children(supervisor) do
    which_children(supervisor)
  end

  def stop_character(pid) do
    terminate_child(@server_mod, pid)
  end
end
