defmodule InmobiliariaWebWeb.RegisterLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.UserManager

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, mensaje: nil)}
  end

  @impl true
  def handle_event("register", params, socket) do
    username = limpiar(params["username"])
    password = limpiar(params["password"])
    rol = limpiar(params["rol"])

    cond do
      username == "" ->
        {:noreply, assign(socket, mensaje: "❌ Debes escribir un usuario")}

      password == "" ->
        {:noreply, assign(socket, mensaje: "❌ Debes escribir una contraseña")}

      rol == "" ->
        {:noreply, assign(socket, mensaje: "❌ Debes seleccionar un rol")}

      true ->
        case UserManager.register_user(username, rol, password) do
          :ok ->
            {:noreply,
             socket
             |> put_flash(:info, "✅ Usuario registrado correctamente")
             |> push_navigate(to: ~p"/?usuario=#{username}&rol=#{rol}")}

          {:error, :already_exists} ->
            {:noreply, assign(socket, mensaje: "❌ Ese usuario ya existe. Inicia sesión.")}

          error ->
            {:noreply, assign(socket, mensaje: "❌ Error al registrar: #{inspect(error)}")}
        end
    end
  end

  defp limpiar(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.downcase()
  end

  defp limpiar(_), do: ""

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-pink-900 to-slate-900 text-white">

      <nav class="w-full bg-slate-950/90 border-b border-white/10 px-8 py-4">
        <div class="max-w-7xl mx-auto flex items-center justify-between">
          <div class="text-white text-xl font-bold">
          🏠 Sistema Inmobiliario
        </div>

          <.link
          navigate={~p"/login"}
          class="rounded-xl bg-white px-5 py-2 text-slate-900 font-bold hover:bg-slate-200 transition"
          >
          Iniciar sesión
          </.link>
        </div>
      </nav>

      <main class="max-w-xl mx-auto px-8 py-20">
        <div class="bg-white text-slate-900 rounded-3xl shadow-2xl p-10">
          <h1 class="text-4xl font-extrabold text-center text-pink-600 mb-4">
            Registrarse
          </h1>

          <p class="text-center text-slate-500 mb-8">
            Crea una cuenta como cliente, vendedor o arrendador.
          </p>

          <%= if @mensaje do %>
            <div class="mb-6 rounded-xl bg-red-100 text-red-700 p-4 font-bold text-center">
              {@mensaje}
            </div>
          <% end %>

          <form phx-submit="register" class="space-y-6">
            <div>
              <label class="block text-lg font-bold mb-2">
                Usuario
              </label>

              <input
                type="text"
                name="username"
                class="w-full rounded-xl border-2 border-pink-300 p-4 text-slate-900 placeholder:text-slate-400"
                placeholder="Ej: carlos"
              />
            </div>

            <div>
              <label class="block text-lg font-bold mb-2">
                Contraseña
              </label>

              <input
                type="password"
                name="password"
                class="w-full rounded-xl border-2 border-pink-300 p-4 text-slate-900 placeholder:text-slate-400"
                placeholder="Ej: 1234"
              />
            </div>

            <div>
              <label class="block text-lg font-bold mb-2">
                Rol
              </label>

              <select
                name="rol"
                class="w-full rounded-xl border-2 border-pink-300 p-4 text-slate-900"
              >
                <option value="cliente">Cliente</option>
                <option value="vendedor">Vendedor</option>
                <option value="arrendador">Arrendador</option>
              </select>
            </div>

            <button
              class="w-full rounded-xl bg-gradient-to-r from-purple-600 to-pink-600 text-white py-4 text-xl font-bold hover:scale-105 transition"
            >
              Crear cuenta
            </button>
          </form>

          <div class="mt-8 text-center">
            <.link navigate={~p"/login"} class="text-pink-600 font-bold hover:underline">
              Ya tengo cuenta, iniciar sesión
            </.link>
          </div>
        </div>
      </main>

    </div>
    """
  end
end
