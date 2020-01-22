$LOAD_PATH.unshift './lib'

require 'roda'
require 'dry-schema'

require 'sudoku/types'
require 'sudoku/game'
require 'sudoku/exceptions'
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

    route do |r| # rubocop:disable Metrics/BlockLength
      r.root do # GET /
        '<p>tady bude seznam rout</p>'
      end

      r.on 'games' do # rubocop:disable Metrics/BlockLength
        r.is do
          r.get do # GET /games
            { ids: Game.all_ids }
          end

          r.post do # POST /games
            grid = request.params.fetch('grid', nil)
            game = grid ? Game.with(grid) : Game.generate

            response.status = :created

            Game::Serializer.new(game).to_json
          end
        end

        r.on Integer do |game_id| # rubocop:disable Metrics/BlockLength
          game = Game.get(game_id)

          r.halt(:not_found, { error: 'game not found' }) unless game

          r.is do
            r.get do # GET /games/:game_id
              Game::Serializer.new(game).to_json
            end
          end

          r.patch do
            r.is 'fill_cell' do
              schema = Dry::Schema.JSON do
                required(:row   ).filled(Types::OneToNine)
                required(:column).filled(Types::OneToNine)
                required(:number).filled(Types::OneToNine)
              end

              validation_result = schema.call(r.params)

              if validation_result.success?
                row, column, number = validation_result.to_h.values_at(:row, :column, :number)

                begin
                  updated_game = game.fill_cell(row, column, number)
                rescue Exceptions::InvalidMove => e
                  r.halt(:bad_request, { error: e })
                end

                Game.set(game_id, updated_game)

                Game::Serializer.new(updated_game).to_json
              else
                response.status = :bad_request

                validation_result.errors.to_h
              end
            end

            r.is 'add_note' do
              schema = Dry::Schema.JSON do
                required(:row   ).filled(Types::OneToNine)
                required(:column).filled(Types::OneToNine)
                required(:number).filled(Types::OneToNine)
              end

              validation_result = schema.call(r.params)

              if validation_result.success?
                row, column, number = validation_result.to_h.values_at(:row, :column, :number)

                begin
                  updated_game = game.add_note(row, column, number)
                rescue Exceptions::CellAlreadyFilled => e
                  r.halt(:bad_request, { error: e })
                end

                Game.set(game_id, updated_game)

                Game::Serializer.new(updated_game).to_json
              else
                response.status = :bad_request

                validation_result.errors.to_h
              end
            end
          end
        end
      end
    end
  end
end
