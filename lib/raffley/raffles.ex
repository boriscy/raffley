defmodule Raffley.Raffles do
  alias Raffley.{Repo, Charities.Charity}
  alias Raffley.Raffles.Raffle
  import Ecto.Query

  def subscribe(raffle_id) do
    Phoenix.PubSub.subscribe(Raffley.PubSub, "raffles:#{raffle_id}")
  end

  def broadcast(raffle_id, message) do
    Phoenix.PubSub.broadcast(Raffley.PubSub, "raffles:#{raffle_id}", message)
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id) 
      |> Repo.preload([:charity, winning_ticket: :user])
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
    |> filter_charity(Map.get(params, "charity"))
    |> order(Map.get(params, "order_by"))
    |> preload(:charity)
    |> Repo.all()
  end

  def filter_charity(query, slug) when slug in [nil, ""], do: query

  def filter_charity(query, slug) do
    # from r in query, join: c in Charity, on: c.id == r.charity_id, where: c.slug == ^slug
    from(
      query
      |> join(:inner, [r], c in Charity, on: c.id == r.charity_id)
      |> where([r, c], c.slug == ^slug)
    )
  end

  def filter_prize(query, prize) when prize != "" do
    query
    |> where([r], ilike(r.prize, ^"%#{prize}%"))
  end

  def filter_prize(query, _), do: query

  @statuses Enum.map(Raffle.statuses(), &Atom.to_string/1)
  def filter_status(query, status) when status in @statuses do
    query
    |> where([r], r.status == ^status)
  end

  def filter_status(query, _), do: query

  def order(query, order_is) when is_binary(order_is) do
    case String.match?(order_is, ~r/asc|desc_\w+/) do
      true ->
        [ord, field] = String.split(order_is, "_", parts: 2)
        ord = String.to_existing_atom(ord)
        order(query, {ord, field})

      _ ->
        query
    end
  end

  @order_raffle_fields ~w(id prize ticket_price)
  def order(query, {ord, field}) when field in @order_raffle_fields do
    query |> order_by({^ord, ^String.to_atom(field)})
  end

  def order(query, {ord, "charity"}) do
    from r in query, join: c in Charity, on: c.id == r.charity_id, order_by: [{^ord, c.name}]
  end

  def order(query, _), do: query

  def list_tickets(%Raffle{} = raffle) do
    raffle
    |> Ecto.assoc(:tickets)
    |> order_by(desc: :inserted_at)
    |> preload(:user)
    |> Repo.all()
  end
end
