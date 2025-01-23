<script>
  let { raffles } = $props()
</script>

{#each raffles as raffle}
  <div class="grid grid-cols-2">
    <div>
      <img src={raffle.image_path} width="150" />
      <span class="badge">{raffle.status}</span>
    </div>
    <div>
      {raffle.prize}: ${raffle.ticket_price}
    </div>
    <p>{@html raffle.description}</p>
  </div>
{/each}
