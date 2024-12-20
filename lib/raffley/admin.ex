defmodule Raffley.Admin do
  alias Raffley.{Raffles.Raffle, Repo}
  import Ecto.Query

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    Raffle.changeset(%Raffle{}, attrs)
    |> Repo.insert()
  end

  def update_raffle(raffle, attrs \\ %{}) do
    Raffle.changeset(raffle, attrs)
    |> Repo.update()
  end

  def delete_raffle(id) do
    raffle = get_raffle!(id)
    Repo.delete(raffle)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def change_raffle(%Raffle{} = raffle, attrs \\ %{}) do
    Raffle.changeset(raffle, attrs)
  end
end
