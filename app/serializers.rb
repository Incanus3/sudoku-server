module Sudoku
  class Game
    class Serializer
      def initialize(game)
        @game = game
      end

      def to_json(*args)
        { id: @game.id, grid: @game.grid.matrix, finished: @game.finished? }.to_json(*args)
      end
    end
  end
end
