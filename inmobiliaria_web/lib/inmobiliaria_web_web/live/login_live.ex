defmodule InmobiliariaWebWeb.LoginLive do
  use InmobiliariaWebWeb, :live_view

  alias ProyectoInmobiliaria.UserManager

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, mensaje: nil)}
  end

  @impl true
  def handle_event("login", params, socket) do
    username = limpiar(params["username"])
    password = limpiar(params["password"])

    cond do
      username == "" ->
        {:noreply, assign(socket, mensaje: "❌ Debes escribir un usuario")}

      password == "" ->
        {:noreply, assign(socket, mensaje: "❌ Debes escribir una contraseña")}

      true ->
        case UserManager.authenticate(username, password) do
          {:ok, user} ->
            {:noreply,
             push_navigate(socket,
               to: ~p"/?usuario=#{user.username}&rol=#{user.rol}"
             )}

          {:error, :invalid_credentials} ->
            {:noreply, assign(socket, mensaje: "❌ Contraseña incorrecta")}

          {:error, :not_found} ->
            {:noreply, assign(socket, mensaje: "❌ El usuario no existe. Regístrate primero.")}
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
    <div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 text-white">

      <nav class="w-full bg-slate-950/90 border-b border-white/10 px-8 py-4">
  <div class="max-w-7xl mx-auto flex items-center justify-between">
    <div class="text-white text-xl font-bold">
      🏠 Sistema Inmobiliario
    </div>

    <.link
      navigate={~p"/registro"}
      class="rounded-xl bg-gradient-to-r from-purple-600 to-pink-600 px-5 py-2 text-white font-bold hover:scale-105 transition"
    >
      Registrarse
    </.link>
  </div>
</nav>

      <main class="max-w-xl mx-auto px-8 py-20">
        <div class="bg-white text-slate-900 rounded-3xl shadow-2xl p-10">
          <h1 class="text-4xl font-extrabold text-center text-purple-700 mb-4">
            Iniciar sesión
          </h1>

          <p class="text-center text-slate-500 mb-8">
            Ingresa con tu usuario y contraseña.
          </p>

          <%= if @mensaje do %>
            <div class="mb-6 rounded-xl bg-red-100 text-red-700 p-4 font-bold text-center">
              {@mensaje}
            </div>
          <% end %>

          <form phx-submit="login" class="space-y-6">
            <div>
              <label class="block text-lg font-bold mb-2">
                Usuario
              </label>

              <input
                type="text"
                name="username"
                class="w-full rounded-xl border-2 border-purple-300 p-4 text-slate-900 placeholder:text-slate-400"
                placeholder="Ej: samuel"
              />
            </div>

            <div>
              <label class="block text-lg font-bold mb-2">
                Contraseña
              </label>

              <input
                type="password"
                name="password"
                class="w-full rounded-xl border-2 border-purple-300 p-4 text-slate-900 placeholder:text-slate-400"
                placeholder="Ej: 1234"
              />
            </div>

            <button
              class="w-full rounded-xl bg-purple-700 hover:bg-purple-800 text-white py-4 text-xl font-bold transition"
            >
              Entrar
            </button>
          </form>

          <div class="mt-8 text-center">
            <p class="text-slate-500 mb-4">
              ¿No tienes cuenta?
            </p>

            <.link
              navigate={~p"/registro"}
              class="inline-block rounded-xl bg-gradient-to-r from-purple-600 to-pink-600 px-8 py-4 text-white font-bold hover:scale-105 transition"
            >
              Registrarse
            </.link>
          </div>
        </div>
      </main>

    </div>
    """
  end
end
