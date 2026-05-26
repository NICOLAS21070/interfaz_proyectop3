defmodule InmobiliariaWebWeb.PropertiesLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.Property
  alias ProyectoInmobiliaria.PropertyManager
  alias ProyectoInmobiliaria.UserManager

  @impl true
  def mount(params, _session, socket) do
    usuario = Map.get(params, "usuario", nil)
    rol = Map.get(params, "rol", nil)

    propiedades =
      cargar_propiedades_para_usuario(usuario, rol)

    filtros = %{
      "tipo" => "",
      "modalidad" => "",
      "ubicacion" => "",
      "estado" => "",
      "precio_max" => ""
    }

    {:ok,
     assign(socket,
      usuario: usuario,
      rol: rol,
      propiedades: propiedades,
      propiedades_filtradas: propiedades,
      filtros: filtros,
      mensaje: nil,
      editando_id: nil,
      form_edicion: %{}
      )
    }end

  # =========================
  # CARGA POR ROL
  # =========================

  defp cargar_propiedades_para_usuario(usuario, rol) do
    PropertyManager.load_properties()
    |> filtrar_por_rol(usuario, rol)
  end

  defp filtrar_por_rol(propiedades, usuario, rol) do
    case rol do
      "cliente" ->
        propiedades

      "vendedor" ->
        Enum.filter(propiedades, fn propiedad ->
          propiedad.propietario == usuario
        end)

      "arrendador" ->
        Enum.filter(propiedades, fn propiedad ->
          propiedad.propietario == usuario
        end)

      _ ->
        []
    end
  end

  # =========================
  # FILTRAR
  # =========================

  @impl true
  def handle_event("filtrar", params, socket) do
    filtros = %{
      "tipo" => Map.get(params, "tipo", ""),
      "modalidad" => Map.get(params, "modalidad", ""),
      "ubicacion" => Map.get(params, "ubicacion", ""),
      "estado" => Map.get(params, "estado", ""),
      "precio_max" => Map.get(params, "precio_max", "")
    }

    propiedades_filtradas =
      socket.assigns.propiedades
      |> filtrar_propiedades(filtros)

    {:noreply,
     assign(socket,
       filtros: filtros,
       propiedades_filtradas: propiedades_filtradas
     )}
  end

  defp filtrar_propiedades(propiedades, filtros) do
    Enum.filter(propiedades, fn propiedad ->
      cumple_tipo?(propiedad, filtros["tipo"]) and
        cumple_modalidad?(propiedad, filtros["modalidad"]) and
        cumple_ubicacion?(propiedad, filtros["ubicacion"]) and
        cumple_estado?(propiedad, filtros["estado"]) and
        cumple_precio?(propiedad, filtros["precio_max"])
    end)
  end

  defp cumple_tipo?(_propiedad, ""), do: true
  defp cumple_tipo?(propiedad, tipo), do: propiedad.tipo == tipo

  defp cumple_modalidad?(_propiedad, ""), do: true
  defp cumple_modalidad?(propiedad, modalidad), do: propiedad.modalidad == modalidad

  defp cumple_estado?(_propiedad, ""), do: true
  defp cumple_estado?(propiedad, estado), do: propiedad.estado == estado

  defp cumple_ubicacion?(_propiedad, ""), do: true

  defp cumple_ubicacion?(propiedad, ubicacion) do
    propiedad.ubicacion
    |> String.downcase()
    |> String.contains?(String.downcase(ubicacion))
  end

  defp cumple_precio?(_propiedad, ""), do: true

  defp cumple_precio?(propiedad, precio_max) do
    case Integer.parse(precio_max) do
      {precio, _} -> propiedad.precio <= precio
      :error -> true
    end
  end

  # =========================
  # COMPRAR
  # =========================

  @impl true
  def handle_event("comprar", %{"id" => id}, socket) do
    cond do
      socket.assigns.rol != "cliente" ->
        {:noreply,
         assign(socket,
           mensaje: "❌ Solo un cliente puede comprar propiedades"
         )}

      true ->
        comprar_propiedad(id, socket)
    end
  end

  defp comprar_propiedad(id, socket) do
    cliente = socket.assigns.usuario || "visitante"

    resultado =
      Property.buy(id, cliente)

    case resultado do
      {:ok, propiedad} ->
        UserManager.update_score(propiedad.propietario, 15)

        guardar_resultado(propiedad, cliente, "compra", "vendida")

        recargar_propiedades(socket, "✅ Propiedad vendida. +15 pts para #{propiedad.propietario}")

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
    cond do
      socket.assigns.rol != "cliente" ->
        {:noreply,
         assign(socket,
           mensaje: "❌ Solo un cliente puede arrendar propiedades"
         )}

      true ->
        arrendar_propiedad(id, socket)
    end
  end

  defp arrendar_propiedad(id, socket) do
    cliente = socket.assigns.usuario || "visitante"

    resultado =
      Property.rent(id, cliente)

    case resultado do
      {:ok, propiedad} ->
        UserManager.update_score(propiedad.propietario, 15)

        guardar_resultado(propiedad, cliente, "arriendo", "arrendada")

        recargar_propiedades(socket, "✅ Propiedad arrendada. +15 pts para #{propiedad.propietario}")

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
  # MARCAR DISPONIBLE
  # =========================

  @impl true
  def handle_event("disponible", %{"id" => id}, socket) do
    case PropertyManager.find_property(id) do
      {:ok, propiedad} ->
        cond do
          socket.assigns.rol not in ["vendedor", "arrendador"] ->
            {:noreply,
             assign(socket,
               mensaje: "❌ Solo vendedores o arrendadores pueden cambiar el estado"
             )}

          propiedad.propietario != socket.assigns.usuario ->
            {:noreply,
             assign(socket,
               mensaje: "❌ Solo el propietario puede marcar esta propiedad como disponible"
             )}

          true ->
            Property.update_state(id, "disponible")

            recargar_propiedades(socket, "✅ Estado actualizado")
        end

      {:error, _reason} ->
        {:noreply,
         assign(socket,
           mensaje: "❌ No se encontró la propiedad"
         )}
    end
  end

  # =========================
# EDITAR PROPIEDAD
# =========================

@impl true
def handle_event("editar", %{"id" => id}, socket) do
  case PropertyManager.find_property(id) do
    {:ok, propiedad} ->
      cond do
        socket.assigns.rol not in ["vendedor", "arrendador"] ->
          {:noreply,
           assign(socket,
             mensaje: "❌ Solo vendedores o arrendadores pueden editar propiedades"
           )}

        propiedad.propietario != socket.assigns.usuario ->
          {:noreply,
           assign(socket,
             mensaje: "❌ Solo puedes editar tus propias propiedades"
           )}

        true ->
          form_edicion = %{
            "tipo" => propiedad.tipo,
            "ubicacion" => propiedad.ubicacion,
            "precio" => to_string(propiedad.precio),
            "habitaciones" => to_string(propiedad.habitaciones),
            "area" => to_string(propiedad.area)
          }

          {:noreply,
           assign(socket,
             editando_id: id,
             form_edicion: form_edicion,
             mensaje: nil
           )}
      end

    {:error, _reason} ->
      {:noreply,
       assign(socket,
         mensaje: "❌ No se encontró la propiedad"
       )}
  end
end

@impl true
def handle_event("cancelar_edicion", _params, socket) do
  {:noreply,
   assign(socket,
     editando_id: nil,
     form_edicion: %{},
     mensaje: nil
   )}
end

@impl true
def handle_event("guardar_edicion", params, socket) do
  id = socket.assigns.editando_id

  case PropertyManager.find_property(id) do
    {:ok, propiedad_actual} ->
      cond do
        socket.assigns.rol not in ["vendedor", "arrendador"] ->
          {:noreply,
           assign(socket,
             mensaje: "❌ Solo vendedores o arrendadores pueden editar propiedades"
           )}

        propiedad_actual.propietario != socket.assigns.usuario ->
          {:noreply,
           assign(socket,
             mensaje: "❌ No puedes editar una propiedad que no es tuya"
           )}

        true ->
          propiedad_editada = %{
            propiedad_actual
            | tipo: params["tipo"],
              ubicacion: params["ubicacion"],
              precio: parse_integer(params["precio"]),
              habitaciones: parse_integer(params["habitaciones"]),
              area: parse_float(params["area"])
          }

          actualizar_propiedad_en_archivo(propiedad_editada)

          recargar_propiedades(socket, "✅ Propiedad actualizada correctamente")
          |> then(fn {:noreply, socket_actualizado} ->
            {:noreply,
             assign(socket_actualizado,
               editando_id: nil,
               form_edicion: %{}
             )}
          end)
      end

    {:error, _reason} ->
      {:noreply,
       assign(socket,
         mensaje: "❌ No se encontró la propiedad"
       )}
  end
end

defp actualizar_propiedad_en_archivo(propiedad_editada) do
  propiedades =
    PropertyManager.load_properties()
    |> Enum.map(fn propiedad ->
      if propiedad.id == propiedad_editada.id do
        propiedad_editada
      else
        propiedad
      end
    end)

  lineas =
    Enum.map(propiedades, fn propiedad ->
      "#{propiedad.id};#{propiedad.tipo};#{propiedad.modalidad};#{propiedad.ubicacion};#{propiedad.precio};#{propiedad.habitaciones};#{propiedad.area};#{propiedad.estado};#{propiedad.propietario}"
    end)

  File.write!(
    "data/properties.dat",
    Enum.join(lineas, "\n") <> "\n"
  )
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

  # =========================
  # RECARGAR CONSERVANDO ROL Y FILTROS
  # =========================

  defp recargar_propiedades(socket, mensaje) do
    propiedades =
      cargar_propiedades_para_usuario(socket.assigns.usuario, socket.assigns.rol)

    propiedades_filtradas =
      filtrar_propiedades(propiedades, socket.assigns.filtros)

    {:noreply,
     assign(socket,
       propiedades: propiedades,
       propiedades_filtradas: propiedades_filtradas,
       mensaje: mensaje
     )}
  end

  # =========================
  # GUARDAR RESULTADO
  # =========================

  defp guardar_resultado(propiedad, cliente, operacion, estado_final) do
    fecha =
      DateTime.utc_now()
      |> DateTime.to_date()
      |> Date.to_string()

    linea =
      "#{fecha}; cliente=#{cliente}; responsable=#{propiedad.propietario}; propiedad=#{propiedad.id}; operacion=#{operacion}; ubicacion=#{propiedad.ubicacion}; precio=#{propiedad.precio}; status=#{estado_final}"

    File.write!(
      "data/results.log",
      linea <> "\n",
      [:append]
    )
  end
end
