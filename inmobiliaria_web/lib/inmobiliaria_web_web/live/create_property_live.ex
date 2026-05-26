defmodule InmobiliariaWebWeb.CreatePropertyLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.PropertyManager
  alias ProyectoInmobiliaria.PropertySupervisor
  alias ProyectoInmobiliaria.UserManager

  @impl true
  def mount(params, _session, socket) do
    usuario = Map.get(params, "usuario", nil)
    rol = Map.get(params, "rol", nil)

    modalidad =
      case rol do
        "vendedor" -> "venta"
        "arrendador" -> "arriendo"
        _ -> nil
      end

    {:ok,
     assign(socket,
       usuario: usuario,
       rol: rol,
       modalidad: modalidad,
       mensaje: nil
     )}
  end

  @impl true
  def handle_event("guardar", params, socket) do
    cond do
      is_nil(socket.assigns.usuario) ->
        {:noreply,
         assign(socket,
           mensaje: "❌ Debes iniciar sesión para publicar una propiedad"
         )}

      socket.assigns.rol not in ["vendedor", "arrendador"] ->
        {:noreply,
         assign(socket,
           mensaje: "❌ Solo vendedores o arrendadores pueden publicar propiedades"
         )}

      true ->
        guardar_propiedad(params, socket)
    end
  end

  defp guardar_propiedad(params, socket) do
    propietario = socket.assigns.usuario
    modalidad = socket.assigns.modalidad

    rol_propietario =
      case modalidad do
        "venta" -> "vendedor"
        "arriendo" -> "arrendador"
      end

    registrar_usuario_si_no_existe(propietario, rol_propietario)

    propiedad = %PropertyManager{
      id: PropertyManager.generate_id(),
      tipo: params["tipo"],
      modalidad: modalidad,
      ubicacion: params["ubicacion"],
      precio: parse_integer(params["precio"]),
      habitaciones: parse_integer(params["habitaciones"]),
      area: parse_float(params["area"]),
      estado: "disponible",
      propietario: propietario
    }

    case PropertyManager.save_property(propiedad) do
      :ok ->
        PropertySupervisor.start_property(propiedad)

        {:noreply,
         socket
         |> put_flash(:info, "✅ Propiedad publicada correctamente")
         |> push_navigate(
           to: "/propiedades?usuario=#{socket.assigns.usuario}&rol=#{socket.assigns.rol}"
         )}

      {:error, :already_exists} ->
        {:noreply, assign(socket, mensaje: "❌ La propiedad ya existe")}

      error ->
        {:noreply, assign(socket, mensaje: "❌ Error al guardar: #{inspect(error)}")}
    end
  end

  defp registrar_usuario_si_no_existe(username, rol) do
    case UserManager.find_user(username) do
      {:ok, _user} ->
        :ok

      {:error, :not_found} ->
        UserManager.register_user(username, rol, "1234")
    end
  end

  defp parse_integer(value) do
    value
    |> String.trim()
    |> String.to_integer()
  end

  defp parse_float(value) do
    value =
      value
      |> String.trim()
      |> String.replace(",", ".")

    if String.contains?(value, ".") do
      String.to_float(value)
    else
      value
      |> String.to_integer()
      |> Kernel.*(1.0)
    end
  end
end
