defmodule ObservabilityWeb.MetricsLive do
  use ObservabilityWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       metric_stream: false,
       error_metric_stream: false,
       timer_ref: nil,
       error_timer_ref: nil
     )}
  end

  @impl true
  def handle_event("trigger_metric", _params, socket) do
    :telemetry.execute([:metrics, :trigger], %{total: 1}, %{})

    {:noreply,
     socket
     |> put_flash(:info, "Metric triggered successfully!")}
  end

  @impl true
  def handle_event("toggle_metric_stream", _params, socket) do
    current_state = socket.assigns.metric_stream
    new_state = !current_state

    socket =
      if new_state do
        # Start the metric stream
        timer_ref = Process.send_after(self(), :emit_success_metric, 1000)
        assign(socket, timer_ref: timer_ref)
      else
        # Stop the metric stream
        if socket.assigns.timer_ref do
          Process.cancel_timer(socket.assigns.timer_ref)
        end

        assign(socket, timer_ref: nil)
      end

    message =
      if new_state, do: "Success metric stream started!", else: "Success metric stream stopped!"

    {:noreply,
     socket
     |> assign(metric_stream: new_state)
     |> put_flash(:info, message)}
  end

  @impl true
  def handle_event("toggle_error_metric_stream", _params, socket) do
    current_state = socket.assigns.error_metric_stream
    new_state = !current_state

    socket =
      if new_state do
        # Start the error metric stream
        error_timer_ref = Process.send_after(self(), :emit_error_metric, 1000)
        assign(socket, error_timer_ref: error_timer_ref)
      else
        # Stop the error metric stream
        if socket.assigns.error_timer_ref do
          Process.cancel_timer(socket.assigns.error_timer_ref)
        end

        assign(socket, error_timer_ref: nil)
      end

    message =
      if new_state, do: "Error metric stream started!", else: "Error metric stream stopped!"

    {:noreply,
     socket
     |> assign(error_metric_stream: new_state)
     |> put_flash(:info, message)}
  end

  @impl true
  def handle_info(:emit_success_metric, socket) do
    if socket.assigns.metric_stream do
      # Emit the metric with success status
      :telemetry.execute([:metrics, :stream], %{total: 1}, %{
        status: :success
      })

      # Schedule the next emission
      timer_ref = Process.send_after(self(), :emit_success_metric, 1000)
      {:noreply, assign(socket, timer_ref: timer_ref)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:emit_error_metric, socket) do
    if socket.assigns.error_metric_stream do
      # Emit the metric with error status
      :telemetry.execute([:metrics, :stream], %{total: 1}, %{
        status: :error
      })

      # Schedule the next emission
      error_timer_ref = Process.send_after(self(), :emit_error_metric, 1000)
      {:noreply, assign(socket, error_timer_ref: error_timer_ref)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-b from-indigo-100 to-white">
      <div class="container mx-auto px-6 py-8">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-semibold text-indigo-600">Metrics Pillar</h2>
          <div class="w-24 h-1 bg-indigo-500 mx-auto mt-4 mb-6"></div>
          <p class="text-gray-600 max-w-2xl mx-auto">
            Trigger metrics with the buttons below
          </p>
        </div>

        <div class="bg-white rounded-xl shadow-lg p-8 mb-10 max-w-4xl mx-auto">
          <div class="flex flex-col space-y-6 md:flex-row md:space-y-0 md:space-x-6 md:justify-center">
            <.button
              phx-click="trigger_metric"
              class="!bg-indigo-600 !hover:bg-indigo-700 text-lg py-3 px-6 rounded-lg shadow-md transition-all duration-300 transform hover:scale-105"
            >
              Trigger Metric
            </.button>

            <.button
              phx-click="toggle_metric_stream"
              class={
                if @metric_stream do
                  "flex items-center justify-center !bg-green-400 !hover:bg-green-500 text-lg py-3 px-6 rounded-lg shadow-md transition-all duration-300 transform hover:scale-105"
                else
                  "flex items-center justify-center !bg-emerald-600 !hover:bg-emerald-700 text-lg py-3 px-6 rounded-lg shadow-md transition-all duration-300 transform hover:scale-105"
                end
              }
            >
              <span class="mr-2">
                {if @metric_stream, do: "Stop", else: "Start"} Success Metric Stream
              </span>
              <.icon
                name={if @metric_stream, do: "hero-stop-solid", else: "hero-play-solid"}
                class="h-5 w-5"
              />
            </.button>

            <.button
              phx-click="toggle_error_metric_stream"
              class={
                if @error_metric_stream do
                  "flex items-center justify-center !bg-red-400 !hover:bg-red-500 text-lg py-3 px-6 rounded-lg shadow-md transition-all duration-300 transform hover:scale-105"
                else
                  "flex items-center justify-center !bg-red-600 !hover:bg-red-700 text-lg py-3 px-6 rounded-lg shadow-md transition-all duration-300 transform hover:scale-105"
                end
              }
            >
              <span class="mr-2">
                {if @error_metric_stream, do: "Stop", else: "Start"} Error Metric Stream
              </span>
              <.icon
                name={if @error_metric_stream, do: "hero-stop-solid", else: "hero-play-solid"}
                class="h-5 w-5"
              />
            </.button>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-lg p-8 max-w-4xl mx-auto">
          <h2 class="text-2xl font-semibold text-indigo-700 mb-6 border-b border-indigo-100 pb-3">
            Metrics Status
          </h2>
          <div class="flex flex-col space-y-4">
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <div class={
                  if @metric_stream do
                    "w-4 h-4 rounded-full bg-emerald-500 mr-3 animate-pulse"
                  else
                    "w-4 h-4 rounded-full bg-gray-400 mr-3"
                  end
                }>
                </div>
                <span class="text-gray-700 font-medium">Success Metric Stream:</span>
              </div>
              <span class={
                if @metric_stream do
                  "font-bold text-emerald-600 text-lg"
                else
                  "font-bold text-gray-600 text-lg"
                end
              }>
                {if @metric_stream, do: "Running", else: "Stopped"}
              </span>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <div class={
                  if @error_metric_stream do
                    "w-4 h-4 rounded-full bg-red-500 mr-3 animate-pulse"
                  else
                    "w-4 h-4 rounded-full bg-gray-400 mr-3"
                  end
                }>
                </div>
                <span class="text-gray-700 font-medium">Error Metric Stream:</span>
              </div>
              <span class={
                if @error_metric_stream do
                  "font-bold text-red-600 text-lg"
                else
                  "font-bold text-gray-600 text-lg"
                end
              }>
                {if @error_metric_stream, do: "Running", else: "Stopped"}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
