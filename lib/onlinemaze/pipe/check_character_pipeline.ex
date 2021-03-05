defmodule Onlinemaze.Pipe.CheckCharacterPipeline do
  alias Onlinemaze.Usecases.Character

  def init(default), do: default

  def call(%Plug.Conn{params: %{"room_name" => room_name, "me" => me}} = conn, _default) do
    if(Character.check_name(String.to_atom(room_name), Character.generate_id(room_name, me))) do
      conn
    else
      raise(Plug.BadRequestError)
    end
  end

  def call(conn, _params) do
    conn
  end
end
