defmodule InmobiliariaWebWeb.PageController do
  use InmobiliariaWebWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
