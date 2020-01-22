require 'sudoku/refinements'
require 'sudoku/exceptions'

module Sudoku
  class Grid
    using Inclusion
    using Duplication

    attr_reader :matrix

    def initialize(matrix)
      @matrix = matrix
    end

    def cell_value(row_number, column_number)
      self.matrix[row_number - 1][column_number - 1]
    end

    def cell_filled?(row_number, column_number)
      !cell_value(row_number, column_number).nil?
    end

    def fill_cell(row_number, column_number, number)
      if number.in?(nth_row(row_number))
        raise Exceptions::NumberAlreadyPresentInRow.new(number, row_number)
      end

      if number.in?(nth_column(column_number))
        raise Exceptions::NumberAlreadyPresentInColumn.new(number, column_number)
      end

      if number.in?(segment_for(row_number, column_number))
        segment_number = segment_number_for(row_number, column_number)

        raise Exceptions::NumberAlreadyPresentInSegment.new(number, segment_number)
      end

      self.class.new(self.matrix.deep_dup.tap { |m| m[row_number - 1][column_number - 1] = number })
    end

    def completely_filled?
      @matrix.all?(&:all?)
    end

    private

    def nth_row(row_number)
      self.matrix[row_number - 1]
    end

    def nth_column(column_number)
      self.matrix.map { |row| row[column_number - 1] }
    end

    def segment_for(row_number, column_number)
      row_start    = (row_number    - 1) / 3 * 3
      column_start = (column_number - 1) / 3 * 3

      self.matrix[row_start, 3].flat_map { |row| row[column_start, 3] }
    end

    def segment_number_for(row_number, column_number)
      (row_number - 1) / 3 * 3 + (column_number - 1) / 3 + 1
    end
  end
end
