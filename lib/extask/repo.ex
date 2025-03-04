defmodule Extask.Repo do
  use Ecto.Repo,
    otp_app: :extask,
    adapter: Ecto.Adapters.Postgres
end
