defmodule RaffeleyWeb.RuleController do
  use RaffeleyWeb, :controller

  def index(conn, _params) do
    # |> String.duplicate(5)
    emojis = ~w(👍🏼 😂 🤘🏼 🎉) |> Enum.shuffle() |> Enum.join()

    rules = Raffeley.Rules.list_rules()

    render(conn, :index, emojis: emojis, rules: rules)
  end

  def show(conn, %{"id" => id}) do
    rule = Raffeley.Rules.get_rule(id)

    render(conn, :show, rule: rule)
  end
end
