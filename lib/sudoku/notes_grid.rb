require 'sudoku/refinements'
require 'sudoku/exceptions'

module Sudoku
  class NotesGrid
    using Duplication

    attr_reader :matrix

    def initialize(matrix = nil)
      @matrix = matrix || (1..9).to_a.then { |numbers| numbers.map { numbers.map { [] } }.freeze }
    end

    def add_note(row_number, column_number, number)
      self.class.new(
        self.matrix.deep_dup.tap do |matrix|
          set_notes_at(matrix, row_number, column_number,
                       (notes_at(row_number, column_number) + [number]).uniq.sort)
        end
      )
    end

    private

    def notes_at(row_number, column_number)
      self.matrix[row_number - 1][column_number - 1]
    end

    def set_notes_at(matrix, row_number, column_number, notes)
      matrix[row_number - 1][column_number - 1] = notes
    end
  end
end
