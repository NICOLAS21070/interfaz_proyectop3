defmodule InmobiliariaWebWeb.MessagesLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.PropertyManager
  alias ProyectoInmobiliaria.MessageManager

  @impl true
  def mount(params, _session, socket) do
    usuario = Map.get(params, "usuario", nil)
    rol = Map.get(params, "rol", nil)

    propiedades = PropertyManager.load_properties()

    propiedad_seleccionada =
      propiedades
      |> List.first()
      |> case do
        nil -> ""
        propiedad -> propiedad.id
      end

    mensajes =
      if propiedad_seleccionada == "" do
        []
      else
        MessageManager.get_messages_for_property(propiedad_seleccionada)
      end

    {:ok,
     assign(socket,
       usuario: usuario,
       rol: rol,
       propiedades: propiedades,
       propiedad_id: propiedad_seleccionada,
       sender: usuario || "",
       message: "",
       mensajes: mensajes,
       aviso: nil
     )}
  end

  @impl true
  def handle_event("seleccionar_propiedad", %{"property_id" => property_id}, socket) do
    mensajes = MessageManager.get_messages_for_property(property_id)

    {:noreply,
     assign(socket,
       propiedad_id: property_id,
       mensajes: mensajes,
       aviso: nil
     )}
  end

  @impl true
  def handle_event("enviar_mensaje", params, socket) do
    property_id = params["property_id"]
    sender = socket.assigns.usuario || limpiar(params["sender"])
    message = limpiar(params["message"])

    case validar_mensaje(property_id, sender, message, socket.assigns.usuario) do
      :ok ->
        recipient = obtener_propietario(property_id)

        MessageManager.send_message(
          property_id,
          sender,
          recipient,
          message
        )

        mensajes = MessageManager.get_messages_for_property(property_id)

        {:noreply,
         assign(socket,
           propiedad_id: property_id,
           sender: sender,
           message: "",
           mensajes: mensajes,
           aviso: "✅ Mensaje enviado correctamente"
         )}

      {:error, texto} ->
        {:noreply, assign(socket, aviso: texto)}
    end
  end

  defp obtener_propietario(property_id) do
    case PropertyManager.find_property(property_id) do
      {:ok, propiedad} -> propiedad.propietario
      {:error, _} -> "desconocido"
    end
  end

  defp validar_mensaje(property_id, sender, message, usuario) do
    cond do
      is_nil(usuario) ->
        {:error, "❌ Debes iniciar sesión para enviar mensajes"}

      property_id == "" ->
        {:error, "❌ Debes seleccionar una propiedad"}

      sender == "" ->
        {:error, "❌ Debes escribir el nombre del remitente"}

      message == "" ->
        {:error, "❌ Debes escribir un mensaje"}

      true ->
        :ok
    end
  end

  defp limpiar(value) when is_binary(value) do
    String.trim(value)
  end

  defp limpiar(_value), do: ""

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-indigo-900 to-slate-900 text-white">

      <nav class="w-full bg-slate-950/90 border-b border-white/10 px-8 py-4">
        <div class="max-w-7xl mx-auto flex items-center justify-between">
          <.link navigate={"/?usuario=#{@usuario}&rol=#{@rol}"} class="text-white text-xl font-bold">
            🏠 Sistema Inmobiliario
          </.link>

          <div class="flex items-center gap-4">
            <.link navigate={"/?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
              Inicio
            </.link>

            <.link navigate={"/propiedades?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
              Propiedades
            </.link>

            <%= if @rol in ["vendedor", "arrendador"] do %>
              <.link navigate={"/crear-propiedad?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
                Crear propiedad
              </.link>
            <% end %>

            <.link navigate={"/ranking?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
              Ranking
            </.link>

            <.link navigate={"/mensajes?usuario=#{@usuario}&rol=#{@rol}"} class="text-white font-bold">
              Mensajes
            </.link>

            <.link navigate={"/resultados?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
              Resultados
            </.link>

            <.link navigate={~p"/login"} class="text-slate-200 hover:text-white transition">
              Cerrar sesión
            </.link>
          </div>
        </div>
      </nav>

      <main class="max-w-6xl mx-auto px-8 py-16">
        <h1 class="text-5xl font-bold mb-4">
          Mensajes
        </h1>

        <p class="text-slate-300 text-xl mb-10">
          Envía mensajes al propietario de una propiedad y consulta el historial guardado.
        </p>

        <%= if @aviso do %>
          <div class="mb-8 rounded-2xl bg-white text-slate-900 px-6 py-4 font-bold">
            {@aviso}
          </div>
        <% end %>

        <%= if is_nil(@usuario) do %>
          <div class="rounded-3xl bg-white text-slate-900 p-10 text-center shadow-2xl">
            <h2 class="text-3xl font-bold mb-4">
              Debes iniciar sesión
            </h2>

            <p class="text-slate-600 mb-8">
              Para enviar mensajes necesitas estar conectado como cliente, vendedor o arrendador.
            </p>

            <.link navigate={~p"/login"} class="inline-block rounded-xl bg-indigo-600 text-white px-8 py-4 font-bold hover:bg-indigo-700 transition">
              Ir a iniciar sesión
            </.link>
          </div>
        <% else %>
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

            <section class="rounded-3xl bg-white text-slate-900 p-8 shadow-2xl">
              <h2 class="text-3xl font-bold mb-6">
                Enviar mensaje
              </h2>

              <%= if Enum.empty?(@propiedades) do %>
                <div class="rounded-2xl bg-yellow-100 text-yellow-800 p-5 font-semibold">
                  Primero debe existir una propiedad para poder enviar mensajes.
                </div>
              <% else %>
                <form phx-submit="enviar_mensaje" class="space-y-5">
                  <div>
                    <label class="block font-bold mb-2">
                      Propiedad
                    </label>

                    <select
                      name="property_id"
                      phx-change="seleccionar_propiedad"
                      class="w-full rounded-xl border-2 border-indigo-200 p-4 text-slate-900"
                    >
                      <%= for propiedad <- @propiedades do %>
                        <option value={propiedad.id} selected={propiedad.id == @propiedad_id}>
                          {propiedad.id} - {propiedad.tipo} en {propiedad.ubicacion} / propietario: {propiedad.propietario}
                        </option>
                      <% end %>
                    </select>
                  </div>

                  <div>
                    <label class="block font-bold mb-2">
                      Remitente
                    </label>

                    <input
                      type="text"
                      name="sender"
                      value={@usuario}
                      readonly
                      class="w-full rounded-xl border-2 border-indigo-200 p-4 text-slate-500 bg-slate-100"
                    />
                  </div>

                  <div>
                    <label class="block font-bold mb-2">
                      Mensaje
                    </label>

                    <textarea
                      name="message"
                      rows="5"
                      class="w-full rounded-xl border-2 border-indigo-200 p-4 text-slate-900 placeholder:text-slate-400"
                      placeholder="Hola, me interesa esta propiedad..."
                    ><%= @message %></textarea>
                  </div>

                  <button
                    class="w-full rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white py-4 text-lg font-bold transition"
                  >
                    Enviar mensaje
                  </button>
                </form>
              <% end %>
            </section>

            <section class="rounded-3xl bg-white/10 border border-white/10 p-8 shadow-2xl">
              <h2 class="text-3xl font-bold mb-6">
                Historial de mensajes
              </h2>

              <%= if @propiedad_id != "" do %>
                <p class="text-slate-300 mb-6">
                  Propiedad seleccionada:
                  <span class="font-bold text-white">{@propiedad_id}</span>
                </p>
              <% end %>

              <%= if Enum.empty?(@mensajes) do %>
                <div class="rounded-2xl bg-white/10 border border-white/10 p-5 text-slate-200">
                  No hay mensajes para esta propiedad.
                </div>
              <% else %>
                <div class="space-y-4">
                  <%= for {timestamp, sender, message} <- @mensajes do %>
                    <div class="rounded-2xl bg-white text-slate-900 p-5">
                      <div class="flex items-center justify-between gap-4 mb-2">
                        <p class="font-bold capitalize">
                          {sender}
                        </p>

                        <p class="text-xs text-slate-500">
                          {timestamp}
                        </p>
                      </div>

                      <p class="text-slate-700">
                        {message}
                      </p>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </section>

          </div>
        <% end %>
      </main>

    </div>
    """
  end
end
