require_relative 'grid'

module Sudoku
  class Puzzle
    attr_reader :grid

    def initialize(grid_or_matrix)
      if grid_or_matrix.is_a?(Grid)
        @grid = grid_or_matrix
      else
        @grid = Grid.new(grid_or_matrix)
      end
    end
  end
end
