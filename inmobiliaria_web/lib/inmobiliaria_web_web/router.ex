defmodule InmobiliariaWebWeb.Router do
  use InmobiliariaWebWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InmobiliariaWebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InmobiliariaWebWeb do
    pipe_through :browser

    # Página principal
    live "/", HomeLive

    # Ver propiedades
    live "/propiedades", PropertiesLive

    # Publicar propiedad
    live "/crear-propiedad", CreatePropertyLive

    # Ranking
    live "/ranking", RankingLive

    # Mensajes
    live "/mensajes", MessagesLive
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:inmobiliaria_web, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: InmobiliariaWebWeb.Telemetry

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
