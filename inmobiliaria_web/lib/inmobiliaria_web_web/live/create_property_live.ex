defmodule InmobiliariaWebWeb.CreatePropertyLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.PropertyManager
  alias ProyectoInmobiliaria.PropertySupervisor

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       mensaje: nil
     )}
  end

  @impl true
  def handle_event("guardar", params, socket) do
    propiedad = %PropertyManager{
      id: PropertyManager.generate_id(),
      tipo: params["tipo"],
      modalidad: params["modalidad"],
      ubicacion: params["ubicacion"],
      precio: String.to_integer(params["precio"]),
      habitaciones: String.to_integer(params["habitaciones"]),
      area: String.to_float(params["area"]),
      estado: "disponible",
      propietario: params["propietario"]
    }

    case PropertyManager.save_property(propiedad) do
      :ok ->

        PropertySupervisor.start_property(propiedad)

        {:noreply,
         assign(socket,
           mensaje: "✅ Propiedad publicada correctamente"
         )}

      {:error, :already_exists} ->

        {:noreply,
         assign(socket,
           mensaje: "❌ La propiedad ya existe"
         )}
    end
  end
end

