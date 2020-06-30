$LOAD_PATH.unshift './lib'

require 'set'

require 'roda'
require 'dry-schema'
require 'async/websocket/adapters/rack'

require 'sudoku/types'
require 'sudoku/game'
require 'sudoku/exceptions'

require_relative 'app/routes'
require_relative 'app/serializers'

# TODO: persist games

module Sudoku
  class App < Roda
    plugin :halt
    plugin :all_verbs
    plugin :not_allowed
    plugin :symbol_status
    plugin :json
    plugin :json_parser
    plugin :websockets

    Connections = Set.new
    EventQueue  = Async::Queue.new

    def subscribe(connection)
      Connections << connection
    end

    def unsubscribe(connection)
      Connections.delete(connection)
    end

    def notify_subscribers(payload)
      message = payload.to_json

      Connections.each do |connection|
        connection.write(message)
        connection.flush
      end
    end

    # rubocop:disable Metrics/BlockLength
    route do |r|
      r.root do # GET /
        '<p>tady bude seznam rout</p>'
      end

      r.on 'games' do
        r.is do
          r.get do # GET /games
            Routes::Games[r].all
          end

          r.post do # POST /games
            Routes::Games[r].create
          end
        end

        r.on Integer do |game_id|
          r.params['game_id'] = game_id

          r.is do
            r.get do # GET /games/:game_id
              Routes::Game[r].get
            end
          end

          r.patch do
            r.is 'fill_cell' do # PATCH /games/:game_id/fill_cell
              Routes::Game[r].fill_cell do |event|
                EventQueue.enqueue(event)
              end
            end

            r.is 'add_note' do # PATCH /games/:game_id/add_note
              Routes::Game[r].add_note
            end
          end

          r.get 'subscribe_for_changes' do
            r.websocket do |connection|
              subscribe(connection)

              while (event = EventQueue.dequeue)
                notify_subscribers(event)
              end
            ensure
              unsubscribe(connection)
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
