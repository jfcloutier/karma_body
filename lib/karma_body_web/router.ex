defmodule KarmaBodyWeb.Router do
  use KarmaBodyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KarmaBodyWeb do
    pipe_through :api

    get "/sensors", BodyController, :sensors
    get "/actuators", BodyController, :actuators

  end
end
