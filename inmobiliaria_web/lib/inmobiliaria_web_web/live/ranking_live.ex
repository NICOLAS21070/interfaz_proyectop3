defmodule InmobiliariaWebWeb.RankingLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.UserManager

  @impl true
  def mount(params, _session, socket) do
    usuario = Map.get(params, "usuario", nil)
    rol = Map.get(params, "rol", nil)

    ranking = UserManager.get_ranking()

    {:ok,
     assign(socket,
       usuario: usuario,
       rol: rol,
       ranking: ranking
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 text-white">

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

            <.link navigate={"/ranking?usuario=#{@usuario}&rol=#{@rol}"} class="text-white font-bold">
              Ranking
            </.link>

            <.link navigate={"/mensajes?usuario=#{@usuario}&rol=#{@rol}"} class="text-slate-200 hover:text-white transition">
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

      <main class="max-w-6xl mx-auto px-8 py-20">
        <h1 class="text-5xl font-bold mb-6">
          Ranking de usuarios
        </h1>

        <p class="text-slate-300 text-xl mb-10">
          Usuarios ordenados según su actividad dentro del sistema inmobiliario.
        </p>

        <div class="rounded-3xl bg-white text-slate-900 shadow-2xl overflow-hidden">
          <div class="bg-purple-700 text-white px-8 py-6">
            <h2 class="text-3xl font-bold">
              Usuarios más activos
            </h2>
          </div>

          <div class="p-8">
            <%= if Enum.empty?(@ranking) do %>
              <div class="text-center text-slate-500 font-semibold py-10">
                Aún no hay usuarios registrados en el ranking.
              </div>
            <% else %>
              <table class="w-full text-left">
                <thead>
                  <tr class="border-b border-slate-200">
                    <th class="py-4">Posición</th>
                    <th class="py-4">Usuario</th>
                    <th class="py-4">Rol</th>
                    <th class="py-4">Puntaje</th>
                  </tr>
                </thead>

                <tbody>
                  <%= for {{usuario, rol, puntaje}, index} <- Enum.with_index(@ranking, 1) do %>
                    <tr class="border-b border-slate-100">
                      <td class="py-4 font-bold">
                        {index}
                      </td>

                      <td class="py-4 capitalize">
                        {usuario}
                      </td>

                      <td class="py-4 capitalize">
                        {rol}
                      </td>

                      <td class="py-4">
                        <span class="bg-purple-600 text-white px-3 py-1 rounded-full text-sm font-bold">
                          {puntaje} pts
                        </span>
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            <% end %>
          </div>
        </div>
      </main>

    </div>
    """
  end
end
