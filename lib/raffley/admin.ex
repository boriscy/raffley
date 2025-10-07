defmodule Raffley.Admin do
  alias Raffley.{Raffles.Raffle, Repo, Raffles}
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
    |> case do
      {:ok, raffle} ->
        raffle = Repo.preload(raffle, :charity)
        Raffles.broadcast(raffle.id, {:raffle_updated, raffle})
        {:ok, raffle}

      {:error, _} = error ->
        error
    end
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

  def draw_winner(%Raffle{status: :closed} = raffle) do
    raffle = Repo.preload(raffle, :tickets)

    case raffle.tickets do
      [] ->
        {:error, "No tickets to draw"}

      tickets ->
        ticket = Enum.random(tickets)
        {:ok, _raffle} = update_raffle(raffle, %{winning_ticket_id: ticket.id})
    end
  end

  def draw_winner(%Raffle{} = _raffle) do
    {:error, "Raffle must be closed to draw a winner"}
  end
end
