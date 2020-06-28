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

    def with_validation(schema, params, &block)
      validation_result = schema.call(params)

      if validation_result.success?
        block.call(validation_result.to_h)
      else
        response.status = :bad_request

        validation_result.errors.to_h
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
            { ids: Game.all_ids }
          end

          r.post do # POST /games
            grid = request.params.fetch('grid', nil)
            game = grid ? Game.with(grid) : Game.generate

            response.status = :created

            Game::Serializer.new(game).to_json
          end
        end

        r.on Integer do |game_id|
          game = Game.get(game_id)

          r.halt(:not_found, { error: 'game not found' }) unless game

          r.is do
            r.get do # GET /games/:game_id
              Game::Serializer.new(game).to_json
            end
          end

          r.patch do
            schema = Dry::Schema.JSON {
              required(:row   ).filled(Types::OneToNine)
              required(:column).filled(Types::OneToNine)
              required(:number).filled(Types::OneToNine)
            }

            r.is 'fill_cell' do # PATCH /games/:game_id/fill_cell
              with_validation(schema, r.params) do |validated_params|
                row, column, number = validated_params.values_at(:row, :column, :number)

                begin
                  updated_game = game.fill_cell(row, column, number)
                rescue Exceptions::InvalidMove => e
                  r.halt(:bad_request, { error: e })
                end

                Game.set(game_id, updated_game)

                Game::Serializer.new(updated_game).to_json
              end
            end

            r.is 'add_note' do # PATCH /games/:game_id/add_note
              with_validation(schema, r.params) do |validated_params|
                row, column, number = validated_params.values_at(:row, :column, :number)

                begin
                  updated_game = game.add_note(row, column, number)
                rescue Exceptions::CellAlreadyFilled => e
                  r.halt(:bad_request, { error: e })
                end

                Game.set(game_id, updated_game)

                Game::Serializer.new(updated_game).to_json
              end
            end
          end
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
