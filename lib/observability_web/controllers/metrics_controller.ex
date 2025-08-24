defmodule ObservabilityWeb.MetricsController do
  use ObservabilityWeb, :controller
  require Logger

  def index(conn, _params) do
    metrics = TelemetryMetricsPrometheus.Core.scrape()

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, metrics)
  end
end
