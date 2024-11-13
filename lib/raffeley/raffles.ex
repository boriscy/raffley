defmodule Raffeley.Raffle do
  defstruct [:id, :prize, :ticket_price, :status, :image_path, :description]
end

defmodule Raffeley.Raffles do
  def list_raffles do
    [
      %Raffeley.Raffle{
        id: 1,
        prize: "Autographed Jersey",
        ticket_price: 2,
        status: :open,
        image_path: "/images/jersey.jpg",
        description: "Step up sports fans! Win this autographed jersey from your favorite player!"
      },
      %Raffeley.Raffle{
        id: 2,
        prize: "Coffee with a Yeti",
        ticket_price: 3,
        status: :upcoming,
        image_path: "/images/yeti-coffee.jpg",
        description: "A yeti power drink coffee"
      },
      %Raffeley.Raffle{
        id: 3,
        prize: "Vintage Comic Book",
        ticket_price: 1,
        status: :closed,
        image_path: "/images/comic-book.jpg",
        description: "A vintage comic book from the 80s"
      }
    ]
  end
end
