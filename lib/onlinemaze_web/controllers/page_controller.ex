defmodule OnlinemazeWeb.PageController do
  use OnlinemazeWeb, :controller
  import Phoenix.LiveView.Controller
  alias Onlinemaze.Usecases.Game

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def new(conn, %{"room_name" => name} = _params) do
    if(Game.check_name(name)) do
      conn
      |> put_flash("error", "すでに存在するルーム名です。別の名前を入力してください。")
      |> render("index.html")
    else
      case Game.create_game(name) do
        {:ok, pid} ->
          conn
          |> live_render(OnlinemazeWeb.RoomLive,
            session: %{"room_name" => name}
          )

        {:error, _error} ->
          put_view(conn, PageView)
          |> render("error.html", message: "Couldn't start a game")
      end
    end
  end

  def play(conn, %{"room_name" => name} = _params) do
    if(Game.check_name(name)) do
      conn
      |> clear_flash()
      |> live_render(OnlinemazeWeb.RoomLive,
        session: %{"room_name" => name}
      )
    else
      conn
      |> put_flash("error", "存在しないルーム名です。新たにルームを作る場合は新規を押してください。")
      |> render("index.html")
    end
  end

  def redirect_to_room(conn, %{"id" => p}) do
    pid =
      p
      |> String.to_atom()
      |> Process.whereis()

    conn
    |> clear_flash()
    |> live_render(OnlinemazeWeb.RoomLive,
      session: %{"game_pid" => pid}
    )
  end

  def redirect_to_coop(conn, %{"me" => me, "room_name" => room_name}) do
    conn
    |> live_render(OnlinemazeWeb.CoopLive,
      session: %{"me" => me, "room_name" => room_name}
    )
  end

  def redirect_to_game(conn, %{"me" => me, "room_name" => room_name}) do
    conn
    |> live_render(OnlinemazeWeb.GameLive,
      session: %{"me" => me, "room_name" => room_name}
    )
  end

  def result(conn, %{"monitor_pid" => pid, "result" => res, "color" => color}) do
    conn
    |> put_session(:review_pid, pid)
    |> put_session(:color, color)
    |> render("result.html", result: res)
  end
end
