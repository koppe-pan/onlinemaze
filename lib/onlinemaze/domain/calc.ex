defmodule Onlinemaze.Domain.Calc do
  alias Onlinemaze.Usecases.Game

  def crossing_wall?(room_name, movement) do
    Game.list_walls(String.to_atom("wall" <> room_name))
    |> Task.async_stream(fn v -> is_other_side?(v, movement) end)
    |> Enum.any?(fn {:ok, v} -> v end)
  end

  def is_other_side?(a, b) do
    calc_is_other_side(a, b) and calc_is_other_side(b, a)
  end

  def calc_is_other_side({a, b}, {c, d}) do
    ((a.x - b.x) * (c.y - a.y) - (c.x - a.x) * (a.y - b.y)) *
      ((a.x - b.x) * (d.y - a.y) - (d.x - a.x) * (a.y - b.y)) <= 0
  end
end
