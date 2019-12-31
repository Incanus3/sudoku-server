require 'sudoku/grid'
require 'sudoku/matrices'

module Sudoku
  class Game
    @mutex   = Mutex.new
    @games   = {}
    @last_id = 0

    attr_reader :id, :grid

    def initialize(id, grid_or_matrix)
      @id   = id
      @grid = if grid_or_matrix.is_a?(Grid)
                grid_or_matrix
              else
                Grid.new(grid_or_matrix)
              end
    end

    def fill_cell(row, column, number)
      with_grid(grid.fill_cell(row, column, number))
    end

    private

    def with_grid(grid)
      self.class.new(id, grid)
    end

    class << self
      def with(grid_or_matrix)
        id   = next_id
        game = Game.new(id, grid_or_matrix)

        @games[id] = game

        game
      end

      def generate
        with(Matrices::ALTERNATING_MATRIX)
      end

      def get(game_id)
        @games[game_id]
      end

      def all_ids
        @games.keys
      end

      private

      def next_id
        @mutex.synchronize { @last_id += 1 }
      end
    end
  end
end
