defmodule KarmaBody.Platform.Brickpi3 do
  @moduledoc """
  The Brickpi3 as body.

  It registers devices, identifies them from dispatched calls by their ids and disaptches to them.
  """

  alias KarmaBody.Platform.Brickpi3.{LegoDevice, LegoDevice.TachoMotor, Sysfs}
  alias KarmaBody.{Platform, Simulation}

  use GenServer

  require Logger

  @behaviour Platform

  @type t :: %__MODULE__{lego_sensors: [LegoDevice.t()], lego_motors: [LegoDevice.t()]}

  @type device_port :: :outA | :outB | :outC | :outD | :in1 | :in2 | :in3 | :in4

  defstruct lego_sensors: [], lego_motors: []

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  @spec init(any()) :: {:ok, KarmaBody.Platform.Brickpi3.t()}
  def init(_opts) do
    if simulated?() do
      :ok = Simulation.register_body()
    end

    {lego_sensors, lego_motors} = initialize_devices()

    {:ok, %__MODULE__{lego_motors: lego_motors, lego_sensors: lego_sensors}}
  end

  @impl Platform
  def device_id(%{type: device_type, port: port}), do: "#{device_type}-#{port}"

  @impl Platform
  def device_type_from_id(device_id) do
    [type_s, _] = String.split(device_id, "-")
    String.to_existing_atom(type_s)
  end

  @impl Platform
  def exposed_sensors() do
    GenServer.call(__MODULE__, :exposed_sensors)
  end

  @impl Platform
  def exposed_actuators() do
    GenServer.call(__MODULE__, :exposed_actuators)
  end

  @impl Platform
  def simulated?(), do: not Sysfs.exists?()

  @impl Platform
  def sense(device_id, sense) do
    if simulated?(),
      do: Simulation.sense(device_id, sense),
      else: GenServer.call(__MODULE__, {:sense, device_id, sense})
  end

  @impl Platform
  def actuate(device_id, action) do
    if simulated?(),
      do: Simulation.actuate(device_id, action),
      else: GenServer.cast(__MODULE__, {:actuate, device_id, action})
  end

  @impl Platform
  def execute_actions() do
    if simulated?(),
      do: Simulation.execute_actions(),
      else: GenServer.cast(__MODULE__, :execute_actions)
  end

  @impl GenServer
  def handle_call(:exposed_sensors, _from, state) do
    sensors = state.lego_sensors |> Enum.map(&to_exposed_sensors/1)
    motor_sensors = state.lego_motors |> Enum.map(&to_exposed_sensors/1)
    all_exposed_sensors = List.flatten(sensors ++ motor_sensors)
    {:reply, all_exposed_sensors, state}
  end

  def handle_call(:exposed_actuators, _from, state),
    do: {:reply, state.lego_motors |> Enum.map(&to_exposed_actuators/1) |> List.flatten(), state}

  def handle_call({:sense, device_id, sense}, _from, state) do
    lego_device = find_device(state.lego_sensors ++ state.lego_motors, device_id)
    value = lego_device.module().sense(lego_device, sense)
    {:reply, value, state}
  end

  @impl GenServer
  def handle_cast({:actuate, device_id, action}, state) do
    lego_device = find_device(state.lego_motors, device_id)
    updated_motor = %{lego_device | actions: lego_device.actions ++ [action]}

    updated_motors =
      List.replace_at(
        state.lego_motors,
        Enum.find_index(state.lego_motors, &(&1.attribute_path == lego_device.attribute_path)),
        updated_motor
      )

    {:noreply, %{state | motors: updated_motors}}
  end

  # Aggregate a list of actions ("spin", "reverse_spin") for each motor and then execute concurrently
  def handle_cast(:execute_actions, state) do
    state.lego_motors
    |> Enum.reduce([], fn motor, acc ->
      [{motor, aggregate_actions(motor)} | acc]
    end)
    |> Enum.into(%{})
    |> Enum.map(fn {motor, execution} ->
      Task.async(fn -> TachoMotor.execute(motor, execution) end)
    end)
    |> Enum.each(&Task.await/1)

    updated_motors =
      Enum.map(state.lego_motors, &%{&1 | actions: []})

    {:noreply, %{state | lego_motors: updated_motors}}
  end

  ###

  defp find_device(devices, device_id) do
    [type_s, port_s] = String.split(device_id, "-")
    type = String.to_atom(type_s)
    port = String.to_atom(port_s)
    Enum.find(devices, &(&1.type == type and &1.port == port))
  end

  defp initialize_devices() do
    Logger.debug("[KarmaBody] Brickpi3 - Initialing devices on the BrickPi3...")

    Application.get_env(:karma_body, :brickpi3)[:devices]
    |> Enum.reduce({[], []}, fn port_config, {sensors_acc, motors_acc} ->
      cond do
        Keyword.has_key?(port_config, :sensor) ->
          lego_sensor = initialize_sensor(port_config)
          {[lego_sensor | sensors_acc], motors_acc}

        Keyword.has_key?(port_config, :motor) ->
          lego_motor = initialize_motor(port_config)
          {sensors_acc, [lego_motor | motors_acc]}
      end
    end)
  end

  defp initialize_sensor(config) do
    port = config[:port]
    sensor_name = config[:sensor]
    # Anything other than port and sensor is a property
    properties = Keyword.drop(config, [:port, :sensor])
    initialize_device(:sensor, port, sensor_name, properties)
  end

  defp initialize_motor(config) do
    port = config[:port]
    motor_name = config[:motor]
    # Anything other than port and motor is a property
    properties = Keyword.drop(config, [:port, :motor])
    initialize_device(:motor, port, motor_name, properties)
  end

  defp initialize_device(device_class, port, device_type, properties) do
    Logger.debug(
      "[KarmaBody] Brickpi3 - Initializing #{inspect(device_type)} #{device_class} on port #{inspect(port)} with properties #{inspect(properties)}}"
    )

    {port_path, attribute_path} = register_device(device_class, port, device_type, properties)

    LegoDevice.make(
      class: device_class,
      type: device_type,
      port: port,
      port_path: port_path,
      attribute_path: attribute_path,
      properties: properties
    )
  end

  defp register_device(device_class, port, device_type, properties) do
    if simulated?() do
      _ =
        Simulation.register_device(
          device_id(%{type: device_type, port: port}),
          device_class,
          device_type,
          properties
        )

      # Return empty port and attribute paths since they are ignored under simulation
      {"", ""}
    else
      Sysfs.register_device(device_class, port, device_type)
    end
  end

  # Aggregate spin and reverse_spin actions into %{polarity: polarity, bursts: bursts}
  defp aggregate_actions(motor) do
    spin_count = Enum.count(motor.actions, &(&1 == "spin"))
    reverse_spin_count = Enum.count(motor.actions, &(&1 == "reverse_spin"))
    bursts = spin_count - reverse_spin_count
    polarity = if bursts >= 0, do: "normal", else: "inversed"
    %{polarity: polarity, bursts: bursts}
  end

  defp to_exposed_sensors(lego_device), do: lego_device.module.to_exposed_sensors(lego_device)
  defp to_exposed_actuators(lego_device), do: lego_device.module.to_exposed_actuators(lego_device)
end
