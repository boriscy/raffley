defmodule Raffley.Raffles do
  alias Raffley.Repo
  alias Raffley.Raffles.Raffle
  import Ecto.Query

  # def get_raffle!(id) when is_binary(id), do: get_raffle!(String.to_integer(id))

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def list_raffles do
    Repo.all(Raffle)
  end

  def featured(raffle) do
    Raffle
    |> where(status: :open)
    |> where([r], r.id != ^raffle.id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end

  def filter_raffles(params \\ %{}) do
    Raffle
    |> filter_prize(Map.get(params, "q"))
    |> filter_status(Map.get(params, "status"))
    |> order(Map.get(params, "order_by"))
    |> Repo.all()
  end

  def filter_prize(query, prize) do
    case prize do
      "" ->
        query

      q ->
        query
        |> where([r], ilike(r.prize, ^"%#{prize}%"))
    end
  end

  def filter_status(query, status) do
    case status do
      "" ->
        query

      st ->
        query
        |> where([r], r.status == ^st)
    end
  end

  def order(query, order_by) do
    case order_by do
      "" ->
        query

      "asc_prize" ->
        query
        |> order_by(asc: :prize)

      "desc_prize" ->
        query
        |> order_by(desc: :prize)

      "asc_ticket_price" ->
        query
        |> order_by(asc: :ticket_price)

      "desc_ticket_price" ->
        query
        |> order_by(desc: :ticket_price)
    end
  end
end
