require 'sudoku/grid'

module Sudoku
  class Game
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

    class << self
      def with(grid_or_matrix)
        id   = next_id
        game = Game.new(id, grid_or_matrix)

        @games[id] = game

        game
      end

      def generate
        with(ALTERNATING_MATRIX)
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
