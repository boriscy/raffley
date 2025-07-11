defmodule Raffley.Raffles.Raffle do
  use Ecto.Schema
  import Ecto.Changeset

  @statuses [:upcoming, :open, :closed]

  schema "raffles" do
    field :status, Ecto.Enum, values: @statuses, default: :upcoming
    field :description, :string
    field :prize, :string
    field :ticket_price, :integer, default: 1
    field :image_path, :string, default: "/images/placeholder.jpg"

    belongs_to :charity, Raffley.Charities.Charity
    has_many :tickets, Raffley.Tickets.Ticket

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(raffle, attrs \\ %{}) do
    raffle
    |> cast(attrs, [:prize, :description, :ticket_price, :status, :image_path, :charity_id])
    |> validate_required([:prize, :description, :ticket_price, :status, :image_path, :charity_id])
    |> validate_length(:prize, min: 4)
    |> validate_length(:description, min: 10)
    |> validate_number(:ticket_price, greater_than: 0)
    |> assoc_constraint(:charity)
  end

  def statuses, do: @statuses
end
