module Sudoku
  class Grid
    numbers = (1..9).to_a

    EMPTY_MATRIX       = (0..8).map { numbers.map { nil } }
    FULL_MATRIX        = (0..8).map { |i| numbers.rotate(i - 1) }
    ALTERNATING_MATRIX = (0..8).map do |i|
      numbers.rotate(i).each_with_index.map { |num, j| num if (i + j).even? }
    end

    TEST_MATRIX = [
      [4,   9,   6,   5,   7,   nil, nil, nil, 2  ],
      [2,   1,   8,   nil, 6,   3,   7,   4,   nil],
      [7,   5,   nil, nil, nil, nil, nil, 9,   nil],
      [5,   nil, 1,   nil, 2,   6,   nil, nil, nil],
      [6,   nil, nil, 3,   nil, 8,   nil, 5,   nil],
      [nil, 2,   nil, 4,   nil, nil, 6,   1,   3  ],
      [9,   nil, nil, nil, nil, 4,   3,   nil, nil],
      [nil, nil, 5,   nil, nil, 7,   4,   nil, nil],
      [3,   nil, nil, 2,   nil, nil, nil, 6,   nil]
    ].freeze

    attr_reader :matrix

    def initialize(matrix)
      @matrix = matrix
    end

    def fill_cell(row, column, number)
      # TODO: validate inputs
      # TODO: use an immutable data structure for matrix

      updated_matrix = @matrix.clone
      updated_matrix[row - 1][column - 1] = number

      self.class.new(updated_matrix)
    end
  end
end
