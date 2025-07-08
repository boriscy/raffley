defmodule Raffley.Tickets do
  @moduledoc """
  The Tickets context.
  """

  import Ecto.Query, warn: false
  alias Raffley.Repo

  alias Raffley.Tickets.Ticket
  alias Raffley.Accounts.User
  alias Raffley.Raffles.Raffle

  @doc """
  Subscribes to scoped notifications about any ticket changes.

  The broadcasted messages match the pattern:

    * {:created, %Ticket{}}
    * {:updated, %Ticket{}}
    * {:deleted, %Ticket{}}

  """

  def subscribe_tickets(%User{} = user) do
    key = user.id

    Phoenix.PubSub.subscribe(Raffley.PubSub, "user:#{key}:tickets")
  end

  defp broadcast(%User{} = user, message) do
    key = user.id

    Phoenix.PubSub.broadcast(Raffley.PubSub, "user:#{key}:tickets", message)
  end

  @doc """
  Returns the list of tickets.

  ## Examples

      iex> list_tickets(scope)
      [%Ticket{}, ...]

  """
  def list_tickets(%User{} = user, %Raffle{} = raffle) do
    Repo.all(
      from ticket in Ticket, where: ticket.user_id == ^user.id and ticket.raffle_id == ^raffle.id
    )
  end

  @doc """
  Gets a single ticket.

  Raises `Ecto.NoResultsError` if the Ticket does not exist.

  ## Examples

      iex> get_ticket!(123)
      %Ticket{}

      iex> get_ticket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ticket!(%User{} = user, id) do
    Repo.get_by!(Ticket, id: id, user_id: user.id)
  end

  @doc """
  Creates a ticket.

  ## Examples

      iex> create_ticket(%{field: value})
      {:ok, %Ticket{}}

      iex> create_ticket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ticket(%User{} = user, %Raffle{} = raffle, attrs \\ %{}) do
    # with {:ok, ticket = %Ticket{}} <-
    #        %Ticket{raffle: raffle, user: user, price: raffle.ticket_price}
    #        |> Ticket.changeset(attrs)
    #        |> Repo.insert() do
    #   # broadcast(user, {:created, ticket})
    #   {:ok, ticket}
    # end
    %Ticket{raffle: raffle, user: user, price: raffle.ticket_price}
    |> Ticket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ticket.

  ## Examples

      iex> update_ticket(ticket, %{field: new_value})
      {:ok, %Ticket{}}

      iex> update_ticket(ticket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ticket(%User{} = user, %Ticket{} = ticket, attrs) do
    true = ticket.user_id == user.id

    with {:ok, ticket = %Ticket{}} <-
           ticket
           |> Ticket.changeset(attrs)
           |> Repo.update() do
      # broadcast(user, {:updated, ticket})
      {:ok, ticket}
    end
  end

  @doc """
  Deletes a ticket.

  ## Examples

      iex> delete_ticket(ticket)
      {:ok, %Ticket{}}

      iex> delete_ticket(ticket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ticket(%User{} = user, %Ticket{} = ticket) do
    true = ticket.user_id == user.id

    with {:ok, ticket = %Ticket{}} <-
           Repo.delete(ticket) do
      broadcast(user, {:deleted, ticket})
      {:ok, ticket}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ticket changes.

  ## Examples

      iex> change_ticket(ticket)
      %Ecto.Changeset{data: %Ticket{}}

  """
  def change_ticket(%Ticket{} = ticket, attrs \\ %{}) do
    # true = ticket.user_id == user.id

    Ticket.changeset(ticket, attrs)
  end
end
