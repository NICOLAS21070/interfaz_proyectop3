defmodule InmobiliariaWebWeb.ResultsLive do
  use InmobiliariaWebWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
  usuario = Map.get(params, "usuario", nil)
  rol = Map.get(params, "rol", nil)

  resultados = cargar_resultados()

  {:ok,
   assign(socket,
     usuario: usuario,
     rol: rol,
     resultados: resultados
   )}
end

  defp cargar_resultados do
    case File.read("data/results.log") do
      {:ok, contenido} ->
        contenido
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_resultado/1)
        |> Enum.reverse()

      {:error, _reason} ->
        []
    end
  end

  defp parse_resultado(linea) do
    partes =
      linea
      |> String.split(";")
      |> Enum.map(&String.trim/1)

    %{
      fecha: obtener_valor(partes, 0),
      cliente: obtener_campo(partes, "cliente"),
      responsable: obtener_campo(partes, "responsable"),
      propiedad: obtener_campo(partes, "propiedad"),
      operacion: obtener_campo(partes, "operacion"),
      ubicacion: obtener_campo(partes, "ubicacion"),
      precio: obtener_campo(partes, "precio"),
      status: obtener_campo(partes, "status")
    }
  end

  defp obtener_valor(partes, index) do
    Enum.at(partes, index, "")
  end

  defp obtener_campo(partes, nombre) do
    partes
    |> Enum.find("", fn parte ->
      String.starts_with?(parte, "#{nombre}=")
    end)
    |> String.replace("#{nombre}=", "")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-emerald-900 to-slate-900 text-white">

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

      <.link navigate={"/mensajes?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
        Mensajes
      </.link>

      <.link navigate={"/resultados?usuario=#{@usuario}&rol=#{@rol}"} class="text-white font-bold">
        Resultados
      </.link>

      <.link navigate={~p"/login"} class="text-slate-200 hover:text-white transition">
        Cerrar sesión
      </.link>
    </div>
  </div>
</nav>

      <main class="max-w-7xl mx-auto px-8 py-16">
        <h1 class="text-5xl font-bold mb-4">
          Historial de operaciones
        </h1>

        <p class="text-slate-300 text-xl mb-10">
          Registro de compras y arriendos realizados dentro del sistema.
        </p>

        <%= if Enum.empty?(@resultados) do %>
          <div class="rounded-3xl bg-white text-slate-900 p-10 text-center shadow-2xl">
            <h2 class="text-3xl font-bold mb-3">
              No hay operaciones registradas
            </h2>

            <p class="text-slate-600">
              Cuando compres o arriendes una propiedad, aparecerá aquí el historial.
            </p>
          </div>
        <% else %>
          <div class="rounded-3xl bg-white text-slate-900 shadow-2xl overflow-hidden">
            <div class="bg-emerald-700 text-white px-8 py-6">
              <h2 class="text-3xl font-bold">
                Operaciones registradas
              </h2>
            </div>

            <div class="overflow-x-auto">
              <table class="w-full text-left">
                <thead>
                  <tr class="border-b border-slate-200 bg-slate-50">
                    <th class="py-4 px-5">Fecha</th>
                    <th class="py-4 px-5">Cliente</th>
                    <th class="py-4 px-5">Responsable</th>
                    <th class="py-4 px-5">Propiedad</th>
                    <th class="py-4 px-5">Operación</th>
                    <th class="py-4 px-5">Ubicación</th>
                    <th class="py-4 px-5">Precio</th>
                    <th class="py-4 px-5">Estado</th>
                  </tr>
                </thead>

                <tbody>
                  <%= for resultado <- @resultados do %>
                    <tr class="border-b border-slate-100 hover:bg-slate-50 transition">
                      <td class="py-4 px-5 font-semibold">
                        {resultado.fecha}
                      </td>

                      <td class="py-4 px-5 capitalize">
                        {resultado.cliente}
                      </td>

                      <td class="py-4 px-5 capitalize">
                        {resultado.responsable}
                      </td>

                      <td class="py-4 px-5">
                        {resultado.propiedad}
                      </td>

                      <td class="py-4 px-5 capitalize">
                        <span class="bg-emerald-100 text-emerald-700 px-3 py-1 rounded-full text-sm font-bold">
                          {resultado.operacion}
                        </span>
                      </td>

                      <td class="py-4 px-5">
                        {resultado.ubicacion}
                      </td>

                      <td class="py-4 px-5 font-bold">
                        ${resultado.precio}
                      </td>

                      <td class="py-4 px-5 capitalize">
                        <span class="bg-slate-900 text-white px-3 py-1 rounded-full text-sm font-bold">
                          {resultado.status}
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          </div>
        <% end %>
      </main>

    </div>
    """
  end
end
