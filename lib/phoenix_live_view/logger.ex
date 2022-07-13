defmodule Phoenix.LiveView.Logger do
  @moduledoc """
  Instrumenter to handle logging of `Phoenix.LiveView` and `Phoenix.LiveComponent` life-cycle events.

  ## Installation

  The logger is installed automatically when Live View starts.

  ## Application configuration

  To configure the application log level, add the following to your `config/config.exs`:

  ```elixir
  config :phoenix_live_view, :log_level, :debug
  ```

  By default, the application log level is set to `:info`.

  To disable application logging entirely, add the following to your `config/config.exs`:

  ```elixir
  config :phoenix_live_view, :log_level, false
  ```

  ## Module configuration

  The log level can be overriden for an individual Live View module:

  ```elixir
  use Phoenix.LiveView, log: :debug
  ```

  To disable logging for an individual Live View module:

  ```elixir
  use Phoenix.LiveView, log: false
  ```

  ## Telemetry

  The following `Phoenix.LiveView` and `Phoenix.LiveComponent` events are logged:

  - `[:phoenix, :live_view, :mount, :start]`
  - `[:phoenix, :live_view, :mount, :stop]`
  - `[:phoenix, :live_view, :handle_params, :start]`
  - `[:phoenix, :live_view, :handle_params, :stop]`
  - `[:phoenix, :live_view, :handle_event, :start]`
  - `[:phoenix, :live_view, :handle_event, :stop]`
  - `[:phoenix, :live_component, :handle_event, :start]`
  - `[:phoenix, :live_component, :handle_event, :stop]`

  See the [Telemetry](./guides/server/telemetry.md) guide for more information.

  ## Parameter filtering

  If enabled, `Phoenix.LiveView.Logger` will filter parameters based on the configuration of `Phoenix.Logger`. 
  """

  import Phoenix.LiveView, only: [connected?: 1]

  import Phoenix.Logger, only: [duration: 1, filter_values: 1]

  require Logger

  @doc false
  def install(log_level) do
    handlers = %{
      [:phoenix, :live_view, :mount, :start] => &__MODULE__.live_view_mount_start/4,
      [:phoenix, :live_view, :mount, :stop] => &__MODULE__.live_view_mount_stop/4,
      [:phoenix, :live_view, :handle_params, :start] =>
        &__MODULE__.live_view_handle_params_start/4,
      [:phoenix, :live_view, :handle_params, :stop] => &__MODULE__.live_view_handle_params_stop/4,
      [:phoenix, :live_view, :handle_event, :start] => &__MODULE__.live_view_handle_event_start/4,
      [:phoenix, :live_view, :handle_event, :stop] => &__MODULE__.live_view_handle_event_stop/4,
      [:phoenix, :live_component, :handle_event, :start] =>
        &__MODULE__.live_component_handle_event_start/4,
      [:phoenix, :live_component, :handle_event, :stop] =>
        &__MODULE__.live_component_handle_event_stop/4
    }

    for {key, fun} <- handlers do
      :telemetry.attach({__MODULE__, key}, key, fun, log_level: log_level)
    end
  end

  defp log_level(socket, log_level: log_level) do
    case socket.view.__live__()[:log] do
      nil ->
        log_level

      false ->
        false

      mod_level ->
        mod_level
    end
  end

  @doc false
  def live_view_mount_start(_event, measurement, metadata, config) do
    %{socket: socket, params: params, session: session, uri: _uri} = metadata
    %{system_time: _system_time} = measurement
    level = log_level(socket, config)

    if level && connected?(socket) do
      Logger.log(level, fn ->
        [
          "MOUNT ",
          inspect(socket.view),
          ?\n,
          "  Parameters: ",
          inspect(filter_values(params)),
          ?\n,
          "  Session: ",
          inspect(session)
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_view_mount_stop(_event, measurement, metadata, config) do
    %{socket: socket, params: _params, session: _session, uri: _uri} = metadata
    %{duration: duration} = measurement
    level = log_level(socket, config)

    if level && connected?(socket) do
      Logger.log(level, fn ->
        [
          "Replied in ",
          duration(duration)
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_view_handle_params_start(_event, measurement, metadata, config) do
    %{socket: socket, params: params, uri: _uri} = metadata
    %{system_time: _system_time} = measurement
    level = log_level(socket, config)

    if level && connected?(socket) do
      Logger.log(level, fn ->
        [
          "HANDLE PARAMS",
          ?\n,
          "  View: ",
          inspect(socket.view),
          ?\n,
          "  Parameters: ",
          inspect(filter_values(params))
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_view_handle_params_stop(_event, measurement, metadata, config) do
    %{socket: socket, params: _params, uri: _uri} = metadata
    %{duration: duration} = measurement
    level = log_level(socket, config)

    if level && connected?(socket) do
      Logger.log(level, fn ->
        [
          "Replied in ",
          duration(duration)
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_view_handle_event_start(_event, measurement, metadata, config) do
    %{socket: socket, event: event, params: params} = metadata
    %{system_time: _system_time} = measurement
    level = log_level(socket, config)

    if level do
      Logger.log(level, fn ->
        [
          "HANDLE EVENT",
          ?\n,
          "  View: ",
          inspect(socket.view),
          ?\n,
          "  Event: ",
          inspect(event),
          ?\n,
          "  Parameters: ",
          inspect(filter_values(params))
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_view_handle_event_stop(_event, measurement, metadata, config) do
    %{socket: socket, event: _event, params: _params} = metadata
    %{duration: duration} = measurement
    level = log_level(socket, config)

    if level do
      Logger.log(level, fn ->
        [
          "Replied in ",
          duration(duration)
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_component_handle_event_start(_event, measurement, metadata, config) do
    %{socket: socket, component: component, event: event, params: params} = metadata
    %{system_time: _system_time} = measurement
    level = log_level(socket, config)

    if level do
      Logger.log(level, fn ->
        [
          "HANDLE EVENT",
          ?\n,
          "  Component: ",
          inspect(component),
          ?\n,
          "  View: ",
          inspect(socket.view),
          ?\n,
          "  Event: ",
          inspect(event),
          ?\n,
          "  Parameters: ",
          inspect(filter_values(params))
        ]
      end)
    end

    :ok
  end

  @doc false
  def live_component_handle_event_stop(_event, measurement, metadata, config) do
    %{socket: socket, component: _component, event: _event, params: _params} = metadata
    %{duration: duration} = measurement
    level = log_level(socket, config)

    if level do
      Logger.log(level, fn ->
        [
          "Replied in ",
          duration(duration)
        ]
      end)
    end

    :ok
  end
end
