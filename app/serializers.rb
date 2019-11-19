module Sudoku
  class Game
    class Serializer
      def initialize(game)
        @game = game
      end

      def to_json
        { id: @game.id, grid: @game.puzzle.grid.matrix }
      end
    end
  end
end
