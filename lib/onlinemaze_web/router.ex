defmodule OnlinemazeWeb.Router do
  use OnlinemazeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {OnlinemazeWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :check_character do
    plug(Onlinemaze.Pipe.CheckCharacterPipeline)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OnlinemazeWeb do
    pipe_through [:browser, :check_character]

    get "/", PageController, :index
    post "/new", PageController, :new
    get "/play", PageController, :play
    get "/redirect_to_room", PageController, :redirect_to_room
    get "/redirect_to_coop", PageController, :redirect_to_coop
    get "/redirect_to_game", PageController, :redirect_to_game
    get "/redirect_to_treasure", PageController, :redirect_to_treasure
    get "/redirect_to_lobby_for_spy", PageController, :redirect_to_lobby_for_spy
    get "/redirect_to_spy", PageController, :redirect_to_spy
    live "/room", RoomLive, :index
    live "/coop", CoopLive, :index
    live "/game", GameLive, :index
    live "/treasure", TreasureLive, :index
    live "/lobby_for_spy", LobbyForSpyLive, :index
    live "/spy", SpyLive, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", OnlinemazeWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: OnlinemazeWeb.Telemetry
    end
  end
end
