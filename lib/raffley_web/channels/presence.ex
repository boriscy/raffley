defmodule RaffleyWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :raffley,
    pubsub_server: Raffley.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  defp topic(id), do: "raffle_watchers:#{id}"

  def track_user(id, user) do
    payload = %{
      email: user.email,
      name: user.name,
      online_at: System.system_time(:second)
    }

    {:ok, _} = track(self(), topic(id), user.id, payload)
  end

  def subscribe(id) do
    Phoenix.PubSub.subscribe(Raffley.PubSub, "updates:" <> topic(id))
  end

  def list_users(id) do
    list(topic(id))
    |> Enum.map(fn {id, %{metas: metas}} ->
      %{id: id, metas: metas}
    end)
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {id, _presence} <- joins do
      presence = %{id: id, metas: Map.fetch!(presences, id)}

      Phoenix.PubSub.local_broadcast(
        Raffley.PubSub,
        "updates:" <> topic,
        {:user_joined, presence}
      )
    end

    for {id, _presence} <- leaves do
      metas =
        case Map.fetch(presences, id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      presence = %{id: id, metas: metas}

      Phoenix.PubSub.local_broadcast(
        Raffley.PubSub,
        "updates:" <> topic,
        {:user_left, presence}
      )
    end

    {:ok, state}
  end
end
