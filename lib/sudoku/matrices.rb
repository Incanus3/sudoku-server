module Sudoku
  module Matrices
    numbers = (1..9).to_a

    EMPTY_MATRIX       = (0..8).map { numbers.map { nil } }.freeze
    FULL_MATRIX        = (0..8).map { |i| numbers.rotate(i - 1) }.freeze
    ALTERNATING_MATRIX = (0..8).map do |i|
      numbers.rotate(i).each_with_index.map { |num, j| num if (i + j).even? }
    end.freeze

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

    ALMOST_FINISHED_MATRIX = [
      [4, 9, 6, 5, 7, 1, 8, 3,   2  ],
      [2, 1, 8, 9, 6, 3, 7, 4,   5  ],
      [7, 5, 3, 8, 4, 2, 1, 9,   6  ],
      [5, 3, 1, 7, 2, 6, 9, 8,   4  ],
      [6, 4, 9, 3, 1, 8, 2, 5,   7  ],
      [8, 2, 7, 4, 9, 5, 6, 1,   3  ],
      [9, 6, 2, 1, 5, 4, 3, nil, nil],
      [1, 8, 5, 6, 3, 7, 4, 2,   nil],
      [3, 7, 4, 2, 8, 9, 5, 6,   1  ]
    ].freeze
  end
end
