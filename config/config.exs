# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :karma_body,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :karma_body, KarmaBodyWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: KarmaBodyWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: KarmaBody.PubSub,
  live_view: [signing_salt: "QXtZEiW1"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Rover configuration

config :karma_body,
  platform: :brickpi3

config :karma_body,
  brickpi3: [
    [port: :in1, sensor: :touch],
    # [port: :in1, sensor: :gyro],
    [port: :in2, sensor: :light],
    # The infrared sensor senses channels 1 and 2 of the IR beacon
    [port: :in3, sensor: :infrared, channels: [1, 2]],
    [port: :in4, sensor: :ultrasonic],
    [port: :outA, motor: :large_tacho, polarity: :normal, rotations_per_second: 1],
    [port: :outB, motor: :large_tacho, polarity: :normal, rotations_per_second: 1],
    [port: :outC, motor: :medium_tacho, polarity: :normal, rotations_per_second: 2.5]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
