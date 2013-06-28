json.array!(@games) do |game|
  json.extract! game, :short_code, :game_state
  json.url game_url(game, format: :json)
end
