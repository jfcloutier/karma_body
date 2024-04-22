defmodule KarmaBodyWeb.Router do
  use KarmaBodyWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KarmaBodyWeb do
    pipe_through :api

    get "/sensors", BodyController, :sensors
    get "/effectors", BodyController, :effectors
    get "/sense/:device_id/:sense", BodyController, :sense
    get "/actuate/:device_id/:action", BodyController, :actuate
    get "/execute_actions", BodyController, :execute_actions
  end
end
