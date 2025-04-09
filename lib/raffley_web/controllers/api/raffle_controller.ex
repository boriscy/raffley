defmodule RaffleyWeb.Api.RaffleController do
  use RaffleyWeb, :controller

  alias Raffley.Admin

  # GET /api/raffles
  def index(conn, _params) do
    raffles = Admin.list_raffles()

    render(conn, :index, raffles: raffles)
  end

  # GET /api/raffles/:id
  def show(conn, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)

    render(conn, :show, raffle: raffle)
  end

  # POST /api/raffles
  def create(conn, %{"raffle" => raffle_params}) do
    case Admin.create_raffle(raffle_params) do
      {:ok, raffle} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", "/api/raffles/#{raffle.id}")
        |> render(:show, raffle: raffle)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:error, changeset: changeset)
    end
  end
end
