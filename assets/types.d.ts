export {}

declare global {
  export type StatusType = "upcoming" | "active" | "completed"

  export type RaffleType = {
    status: StatusType
    description: string
    prize: string
    ticket_price: number
    image_path: string
  }
}
