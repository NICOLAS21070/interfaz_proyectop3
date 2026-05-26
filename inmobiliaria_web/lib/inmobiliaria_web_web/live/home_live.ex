defmodule InmobiliariaWebWeb.HomeLive do
  use InmobiliariaWebWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    usuario = Map.get(params, "usuario", nil)
    rol = Map.get(params, "rol", nil)

    {:ok,
     assign(socket,
       usuario: usuario,
       rol: rol
     )}
  end
end
