require 'spec_helper'
require 'sudoku/grid'

module Sudoku
  RSpec.describe Grid do
    subject { Grid.new(Grid::TEST_MATRIX) }

    describe '#fill_cell' do
      it 'fills given cell with given number if empty and valid' do
        updated = subject.fill_cell(9, 9, 9)

        expect(updated.matrix[8][8]).to eq 9
      end

      it 'raises meaningful error if cell out of bounds'
      it 'raises meaningful error if cell already filled'
      it 'raises meaningful error if against rules'
    end
  end
end
