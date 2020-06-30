require 'web/route_set'

module Sudoku
  module Routes
    class Common < Web::RouteSet
      def serialize_game(game)
        Sudoku::Game::Serializer.new(game).to_json
      end
    end

    class Games < Common
      def all
        { ids: Sudoku::Game.all_ids }
      end

      def create
        grid = params.fetch('grid', nil)
        game = grid ? Sudoku::Game.with(grid) : Sudoku::Game.generate

        response.status = :created

        serialize_game(game)
      end
    end

    class Game < Common
      def get
        serialize_game(game)
      end

      def fill_cell
        update_cell do |row, column, number|
          game.fill_cell(row, column, number)
        rescue Exceptions::InvalidMove => e
          request.halt(:bad_request, { error: e })
        end
      end

      def add_note
        update_cell do |row, column, number|
          game.add_note(row, column, number)
        rescue Exceptions::CellAlreadyFilled => e
          request.halt(:bad_request, { error: e })
        end
      end

      private

      def game_id
        request.params['game_id']
      end

      def game
        game = Sudoku::Game.get(game_id)

        request.halt(:not_found, { error: 'game not found' }) unless game

        game
      end

      def persist_game(updated_game)
        Sudoku::Game.set(game_id, updated_game)
      end

      def update_cell
        with_validation(cell_and_number_schema, params) do |validated_params|
          updated_game = yield validated_params.values_at(:row, :column, :number)

          persist_game(updated_game)
          serialize_game(updated_game)
        end
      end

      def cell_and_number_schema
        Dry::Schema.JSON {
          required(:row   ).filled(Types::OneToNine)
          required(:column).filled(Types::OneToNine)
          required(:number).filled(Types::OneToNine)
        }
      end
    end
  end
end
