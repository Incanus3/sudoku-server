module Sudoku
  class Game
    attr_reader :id, :puzzle

    @mutex   = Mutex.new
    @games   = {}
    @last_id = 0

    def initialize(id, puzzle)
      @id     = id
      @puzzle = puzzle
    end

    class << self
      def generate
        id = get_next_id

        matrix = [
          [4,   9,   6,   5,   7,   nil, nil, nil, 2  ],
          [2,   1,   8,   nil, 6,   3,   7,   4,   nil],
          [7,   5,   nil, nil, nil, nil, nil, 9,   nil],
          [5,   nil, 1,   nil, 2,   6,   nil, nil, nil],
          [6,   nil, nil, 3,   nil, 8,   nil, 5,   nil],
          [nil, 2,   nil, 4,   nil, nil, 6,   1,   3  ],
          [9,   nil, nil, nil, nil, 4,   3,   nil, nil],
          [nil, nil, 5,   nil, nil, 7,   4,   nil, nil],
          [3,   nil, nil, 2,   nil, nil, nil, 6,   nil]
        ]

        puzzle = Sudoku::Puzzle.new(matrix)
        game   = Game.new(id, puzzle)

        @games[id] = game

        game
      end

      def get(game_id)
        @games[game_id]
      end

      def all_ids
        @games.keys
      end

      private

      def get_next_id
        @mutex.synchronize { @last_id += 1 }
      end
    end
  end
end
