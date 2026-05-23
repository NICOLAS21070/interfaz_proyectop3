defmodule InmobiliariaWebWeb.PropertiesLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.Property
  alias ProyectoInmobiliaria.PropertyManager

  @impl true
  def mount(_params, _session, socket) do

    propiedades =
      PropertyManager.load_properties()

    {:ok,
      assign(socket,
        propiedades: propiedades,
        mensaje: nil
      )}

  end

  # =========================
  # COMPRAR
  # =========================

  @impl true
  def handle_event("comprar", %{"id" => id}, socket) do

    resultado =
      Property.buy(id, "cliente_web")

    case resultado do

      {:ok, _property} ->

        {:noreply,
          assign(socket,
            propiedades: PropertyManager.load_properties(),
            mensaje: "✅ Propiedad comprada"
          )}

      {:error, :not_available} ->

        {:noreply,
          assign(socket,
            mensaje: "❌ No disponible"
          )}

      error ->

        {:noreply,
          assign(socket,
            mensaje: "ERROR: #{inspect(error)}"
          )}

    end

  end

  # =========================
  # ARRENDAR
  # =========================

  @impl true
  def handle_event("arrendar", %{"id" => id}, socket) do

    resultado =
      Property.rent(id, "cliente_web")

    case resultado do

      {:ok, _property} ->

        {:noreply,
          assign(socket,
            propiedades: PropertyManager.load_properties(),
            mensaje: "✅ Propiedad arrendada"
          )}

      {:error, :not_available} ->

        {:noreply,
          assign(socket,
            mensaje: "❌ No disponible"
          )}

      error ->

        {:noreply,
          assign(socket,
            mensaje: "ERROR: #{inspect(error)}"
          )}

    end

  end

  # =========================
  # DISPONIBLE
  # =========================

  @impl true
  def handle_event("disponible", %{"id" => id}, socket) do

    Property.update_state(id, "disponible")

    {:noreply,
      assign(socket,
        propiedades: PropertyManager.load_properties(),
        mensaje: "✅ Estado actualizado"
      )}

  end

end
