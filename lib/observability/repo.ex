defmodule Observability.Repo do
  use Ecto.Repo,
    otp_app: :observability,
    adapter: Ecto.Adapters.Postgres
end
