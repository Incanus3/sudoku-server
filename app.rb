$LOAD_PATH.unshift './lib'

require 'roda'
require 'sudoku/game'
require_relative 'app/serializers'

# TODO: persist games

module Sudoku
  class App < Roda
    plugin :json
    plugin :json_parser

    route do |r| # rubocop:disable Metrics/BlockLength
      r.root do # GET /
        '<p>tady bude seznam rout</p>'
      end

      r.on 'games' do
        r.is do
          r.get do # GET /games
            { ids: Game.all_ids }
          end

          r.post do # POST /games
            grid = request.params.fetch('grid', nil)
            game = grid ? Game.with(grid) : Game.generate

            response.status = 201

            Game::Serializer.new(game).to_json
          end
        end

        r.is Integer do |game_id|
          r.get do # GET /games/:game_id
            game = Game.get(game_id)

            if game
              Game::Serializer.new(game).to_json
            else
              response.status = 404

              { error: 'game not found' }
            end
          end
        end
      end
    end
  end
end
