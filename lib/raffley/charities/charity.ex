defmodule Raffley.Charities.Charity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "charities" do
    field :name, :string
    field :slug, :string

    has_many(:raffles, Raffley.Raffles.Raffle, on_delete: :delete_all)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(charity, attrs) do
    charity
    |> cast(attrs, [:name, :slug])
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
    |> unique_constraint(:name)
  end
end
