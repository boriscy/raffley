defmodule Raffeley.Repo do
  use Ecto.Repo,
    otp_app: :raffeley,
    adapter: Ecto.Adapters.Postgres
end
