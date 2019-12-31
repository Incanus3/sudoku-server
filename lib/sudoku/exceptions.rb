module Sudoku
  module Exceptions
    InvalidMove = Class.new(RuntimeError)

    class NumberAlreadyPresentInRow < Exceptions::InvalidMove
      def initialize(number, row_number)
        super("number #{number} is already present in row #{row_number}")
      end
    end

    class NumberAlreadyPresentInColumn < Exceptions::InvalidMove
      def initialize(number, column_number)
        super("number #{number} is already present in column #{column_number}")
      end
    end

    class NumberAlreadyPresentInSegment < Exceptions::InvalidMove
      def initialize(number, segment_number)
        super("number #{number} is already present in segment #{segment_number}")
      end
    end
  end
end
