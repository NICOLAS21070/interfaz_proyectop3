defmodule InmobiliariaWebWeb.MessagesLive do
  use InmobiliariaWebWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-10 text-4xl text-white bg-indigo-900 min-h-screen">
      Mensajes
    </div>
    """
  end
end
