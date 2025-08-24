defmodule ObservabilityWeb.PageController do
  use ObservabilityWeb, :controller

  def home(conn, _params) do
    # Use the default app layout to ensure the banner appears
    render(conn, :home)
  end
end
