defmodule KarmaBodyWeb.Router do
  use KarmaBodyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KarmaBodyWeb do
    pipe_through :api

    get "/sensors", BodyController, :sensors
    get "/actuators", BodyController, :actuators
    get "/sense/:id/:sense", BodyController, :sense
    get "/actuate/:actuator_name/:action", BodyController, :actuate
  end
end
