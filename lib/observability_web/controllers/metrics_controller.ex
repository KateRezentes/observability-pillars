defmodule ObservabilityWeb.MetricsController do
  use ObservabilityWeb, :controller

  def index(conn, _params) do
    # Here you would typically use a library like prometheus_ex to generate metrics
    # For now, we'll just return a simple text response
    metrics = """
    # HELP phoenix_requests_total The total number of Phoenix requests.
    # TYPE phoenix_requests_total counter
    phoenix_requests_total 100

    # HELP phoenix_request_duration_milliseconds The Phoenix request duration in milliseconds.
    # TYPE phoenix_request_duration_milliseconds histogram
    phoenix_request_duration_milliseconds_bucket{le="100"} 90
    phoenix_request_duration_milliseconds_bucket{le="300"} 95
    phoenix_request_duration_milliseconds_bucket{le="500"} 99
    phoenix_request_duration_milliseconds_bucket{le="+Inf"} 100
    phoenix_request_duration_milliseconds_sum 10000
    phoenix_request_duration_milliseconds_count 100

    # HELP metrics_pillar_trigger_stream_total The total number of metrics triggered.
    # TYPE metrics_pillar_trigger_stream_total counter
    metrics_pillar_trigger_stream_total{status="success"} 50
    metrics_pillar_trigger_stream_total{status="error"} 10
    """

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, metrics)
  end
end
