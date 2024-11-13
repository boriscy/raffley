defmodule Raffeley.Rules do
  def list_rules do
    [
      %{
        id: 1,
        text: "Slow is smooth, and smooth is fast! 🐢"
      },
      %{
        id: 2,
        text: "Working with a buddy is always a smart move. 👯‍♂️"
      },
      %{
        id: 3,
        text: "Take it easy and enjoy! 😊"
      }
    ]
  end

  def get_rule(id) when is_integer(id) do
    list_rules()
    |> Enum.find(&(&1.id == id))
  end

  def get_rule(id) when is_binary(id) do
    id |> String.to_integer() |> get_rule()
  end
end
