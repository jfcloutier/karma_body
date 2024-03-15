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

config :karma_body, :brickpi3,
  devices: [
    [port: :in1, sensor: :touch, position: :front, orientation: :forward],
    # [port: :in1, sensor: :gyro],
    [port: :in2, sensor: :light, position: :front, orientation: :downward],
    # The infrared sensor senses channels 1 and 2 of the IR beacon
    [port: :in3, sensor: :infrared, channels: [1, 2], position: :front, orientation: :forward],
    [port: :in4, sensor: :ultrasonic, position: :front, orientation: :forward],
    [
      port: :outA,
      motor: :tacho_motor,
      polarity: "normal",
      rpm: 60,
      burst_secs: 1,
      position: :left,
      orientation: :forward
    ],
    [
      port: :outB,
      motor: :tacho_motor,
      polarity: "normal",
      rpm: 60,
      burst_secs: 1,
      position: :right,
      orientation: :forward
    ]
    # [port: :outC, motor: :tacho_motor, polarity: "normal", rpm: 120, burst_secs: 5,position: :front, orientation: :downward]
  ],
  # If the birckpi3 platform is simulated, where to forward device registration, sensing and actuating
  simulation: [host: "http://localhost:4001"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
