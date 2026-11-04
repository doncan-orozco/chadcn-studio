# The most generations the whole site may start in an hour, on top of the per-address rate limit. It bounds what an open host
# can spend on the Anthropic API. GENERATIONS_HOURLY_CAP sets it (default 60); 0 or an empty value turns the cap off.
Rails.application.configure do
  config.x.generations.hourly_cap = ENV.fetch("GENERATIONS_HOURLY_CAP", 60).to_i
end
