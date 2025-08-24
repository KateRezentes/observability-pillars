defmodule ObservabilityWeb.MetricsController do
  use ObservabilityWeb, :controller
  require Logger

  def index(conn, _params) do
    name = :prometheus_metrics
    metrics = TelemetryMetricsPrometheus.Core.scrape(name)
    text(conn, metrics)
  end
end
