defmodule InmobiliariaWebWeb.RankingLive do
  use InmobiliariaWebWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="p-10 text-4xl text-white bg-purple-900 min-h-screen">
      Ranking de usuarios
    </div>
    """
  end
end
