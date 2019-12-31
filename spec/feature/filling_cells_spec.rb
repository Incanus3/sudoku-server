require 'spec_helper'
require 'sudoku/grid'
require 'sudoku/matrices'

RSpec.describe 'filling cells' do # rubocop:disable Metrics/BlockLength
  include JSONRequests

  let(:grid) { Sudoku::Matrices::TEST_MATRIX }

  context 'with valid params' do
    it 'updates the game grid and returns updated game' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { row: 9, column: 9, number: 9 }

      expect(last_response).to be_ok

      returned_grid = Sudoku::Grid.new(last_response.json['grid'])

      expect(returned_grid.cell_value(9, 9)).to eq 9
    end
  end

  context 'with nonexistent game id' do
    it 'returns meaningful error response' do
      id = 666

      patch_json "/games/#{id}/fill_cell", { row: 9, column: 9, number: 9 }

      expect(last_response).to be_not_found
      expect(last_response.json).to eq({ 'error' => 'game not found' })
    end
  end

  context 'with invalid params' do
    it 'returns meaningful error response on missing or empty params' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { column: nil, number: '' }

      expect(last_response).to be_bad_request
      expect(last_response.json['row']   ).to eq ['is missing']
      expect(last_response.json['column']).to eq ['must be an integer']
      expect(last_response.json['number']).to eq ['must be an integer']
    end

    it 'returns meaningful error response on type errors' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { row: nil, column: 5.5, number: '1' }

      expect(last_response).to be_bad_request
      expect(last_response.json['row']   ).to eq ['must be an integer']
      expect(last_response.json['column']).to eq ['must be an integer']
      expect(last_response.json['number']).to eq ['must be an integer']
    end

    it 'returns meaningful error response on value errors' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { row: 0, column: 10, number: 5.5 }

      expect(last_response).to be_bad_request
      expect(last_response.json['row']   ).to eq ['must be greater than or equal to 1']
      expect(last_response.json['column']).to eq ['must be less than or equal to 9']
      expect(last_response.json['number']).to eq ['must be an integer']
    end
  end

  context 'when against rules' do
    it 'returns meaningful error response when number already present in row' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { row: 1, column: 6, number: 9 }

      expect(last_response).to be_bad_request
      expect(last_response.json['error']).to eq 'number 9 is already present in row 1'
    end

    it 'returns meaningful error response when number already present in column' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { row: 6, column: 1, number: 9 }

      expect(last_response).to be_bad_request
      expect(last_response.json['error']).to eq 'number 9 is already present in column 1'
    end

    it 'returns meaningful error response when number already present in segment' do
      post_json '/games', { grid: grid }

      id = last_response.json['id']

      patch_json "/games/#{id}/fill_cell", { row: 2, column: 9, number: 9 }

      expect(last_response).to be_bad_request
      expect(last_response.json['error']).to eq 'number 9 is already present in segment 3'
    end
  end
end
