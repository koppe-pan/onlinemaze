defmodule Onlinemaze.Domain.Mode do
  def check(characters, mode) do
    characters
    |> Enum.count(fn v -> GenServer.call(v, :mode) == mode end) <
      mode_max(mode)
  end

  def mode_max("room"), do: 30
  def mode_max("treasure"), do: 30
  def mode_max("game"), do: 30
  def mode_max("coop"), do: 30
  def mode_max("lobby_for_spy"), do: 4
  def mode_max("spy"), do: 4
end
