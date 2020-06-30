require 'async'
require 'async/io/stream'
require 'async/http/endpoint'
require 'async/websocket/client'

URL = 'http://localhost:9292/games/1/subscribe_for_changes'
nonce = (0...50).map { ('a'..'z').to_a[rand(26)] }.join

# rubocop:disable Metrics/BlockLength
Async do |task|
  endpoint = Async::HTTP::Endpoint.parse(URL)

  Async::WebSocket::Client.connect(endpoint) do |connection|
    puts "client: established connection"

    connection.write({ user: nonce, status: 'connected' })

    while (message = connection.read)
      puts "client received #{JSON.parse(message).inspect}"
    end
  end
end
# rubocop:enable Metrics/BlockLength
