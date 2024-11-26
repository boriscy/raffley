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

      _ ->
        query
        |> where([r], ilike(r.prize, ^"%#{prize}%"))
    end
  end

  def filter_status(query, status) do
    case status do
      "" ->
        query

      _ ->
        query
        |> where([r], r.status == ^status)
    end
  end

  defp order(query, nil, _), do: query

  defp order(query, field, :asc), do: query |> order_by(asc: ^field)
  defp order(query, field, :desc), do: query |> order_by(desc: ^field)

  @order_fields ["prize", "ticket_price"]
  def order(query, order_by) do
    [field, order] =
      case order_by do
        "asc_" <> field ->
          [field, :asc]

        "desc_" <> field ->
          [field, :desc]

        _ ->
          [nil, nil]
      end

    field = Enum.find(@order_fields, &(&1 == field))

    order(query, field, order)
  end
end
