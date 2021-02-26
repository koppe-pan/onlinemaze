defmodule OnlinemazeWeb.PageController do
  use OnlinemazeWeb, :controller
  import Phoenix.LiveView.Controller
  alias Onlinemaze.Usecases.{Character, Game}

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
        {:ok, _} ->
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

  def redirect_to_room(conn, %{"me" => me, "room_name" => room_name}) do
    if(Character.check_name(String.to_atom(room_name), Character.generate_id(room_name, me))) do
      conn
      |> live_render(OnlinemazeWeb.RoomLive,
        session: %{"me" => me, "room_name" => room_name}
      )
    else
      conn
      |> put_flash("error", "存在しないルーム名またはキャラクター名です。")
      |> render("index.html")
    end
  end

  def redirect_to_coop(conn, %{"me" => me, "room_name" => room_name}) do
    if(Character.check_name(String.to_atom(room_name), Character.generate_id(room_name, me))) do
      conn
      |> live_render(OnlinemazeWeb.CoopLive,
        session: %{"me" => me, "room_name" => room_name}
      )
    else
      conn
      |> put_flash("error", "存在しないルーム名またはキャラクター名です。")
      |> render("index.html")
    end
  end

  def redirect_to_game(conn, %{"me" => me, "room_name" => room_name}) do
    if(Character.check_name(String.to_atom(room_name), Character.generate_id(room_name, me))) do
      conn
      |> live_render(OnlinemazeWeb.GameLive,
        session: %{"me" => me, "room_name" => room_name}
      )
    else
      conn
      |> put_flash("error", "存在しないルーム名またはキャラクター名です。")
      |> render("index.html")
    end
  end

  def redirect_to_treasure(conn, %{"me" => me, "room_name" => room_name}) do
    me_pid = Character.generate_id(room_name, me)

    if(Character.check_name(String.to_atom(room_name), me_pid)) do
      Character.change_mode(me_pid, "treasure")

      conn
      |> live_render(OnlinemazeWeb.TreasureLive,
        session: %{"me" => me, "room_name" => room_name}
      )
    else
      conn
      |> put_flash("error", "存在しないルーム名またはキャラクター名です。")
      |> render("index.html")
    end
  end

  def result(conn, %{"monitor_pid" => pid, "result" => res, "color" => color}) do
    conn
    |> put_session(:review_pid, pid)
    |> put_session(:color, color)
    |> render("result.html", result: res)
  end
end
