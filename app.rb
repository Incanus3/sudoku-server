$LOAD_PATH.unshift './lib'

require 'roda'
require 'dry-schema'

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
              Routes::Game[r].fill_cell
            end

            r.is 'add_note' do # PATCH /games/:game_id/add_note
              Routes::Game[r].add_note
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
