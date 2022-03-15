defmodule TheBrogrammer.Repo do
  use Ecto.Repo,
    otp_app: :the_brogrammer,
    adapter: Ecto.Adapters.Postgres
end
