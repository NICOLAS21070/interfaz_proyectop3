defmodule InmobiliariaWebWeb.HomeLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.PropertyManager

  @impl true
  def mount(_params, _session, socket) do

    {:ok,
      assign(socket,
        propiedades: PropertyManager.load_properties()
      )}

  end

  @impl true
  def handle_event("comprar", %{"id" => id}, socket) do

    PropertyManager.update_property_state(
      id,
      "vendida"
    )

    {:noreply,
      assign(socket,
        propiedades: PropertyManager.load_properties()
      )}

  end

  @impl true
  def handle_event("reservar", %{"id" => id}, socket) do

    PropertyManager.update_property_state(
      id,
      "reservada"
    )

    {:noreply,
      assign(socket,
        propiedades: PropertyManager.load_properties()
      )}

  end
end
