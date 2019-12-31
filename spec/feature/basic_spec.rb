require 'spec_helper'
require 'sudoku/grid'

RSpec.describe do # rubocop:disable Metrics/BlockLength
  include JSONRequests

  describe 'root route' do
    it 'works' do
      get '/'

      expect(last_response).to be_ok
      expect(last_response.body).to include 'tady bude seznam rout'
    end
  end

  describe 'game flow' do
    it 'creates, lists and returns games' do
      get '/games'

      expect(last_response).to be_ok
      expect(last_response.json['ids']).to be_empty

      post '/games'

      expect(last_response).to be_created

      id = last_response.json['id']

      get '/games'

      expect(last_response).to be_ok
      expect(last_response.json['ids']).to include id

      get "/games/#{id}"

      expect(last_response).to be_ok
      expect(last_response.json['id']).to eq id
      expect(last_response.json['grid']).to have(9).rows
      expect(last_response.json['grid']).to all(have(9).columns)

      get '/games/666'

      expect(last_response).to be_not_found
    end
  end

  describe 'create game with specified grid' do
    it 'creates the game with given grid' do
      post_json '/games', { grid: Sudoku::Grid::FULL_MATRIX }

      expect(last_response).to be_created
      expect(last_response.json['grid']).to eq Sudoku::Grid::FULL_MATRIX
    end
  end

  describe 'filling cells' do
    context 'with valid params' do
      it 'updates the game grid and returns updated game' do
        post_json '/games', { grid: Sudoku::Grid::TEST_MATRIX }

        id = last_response.json['id']

        patch_json "/games/#{id}/fill_cell", { row: 9, column: 9, number: 9 }

        expect(last_response).to be_ok
        expect(last_response.json['grid'][8][8]).to eq 9
      end
    end

    context 'with invalid params' do
      it 'returns meaningful error response on missing param' do
        post_json '/games', { grid: Sudoku::Grid::TEST_MATRIX }

        id = last_response.json['id']

        patch_json "/games/#{id}/fill_cell", { row: nil, column: 'a' }

        expect(last_response).to be_bad_request
        expect(last_response.json['row']   ).to eq ['must be filled']
        expect(last_response.json['column']).to eq ['must be an integer']
        expect(last_response.json['number']).to eq ['is missing']
      end
    end

    context 'with nonexistent game id' do
      it 'returns meaningful error' do
        id = 666

        patch_json "/games/#{id}/fill_cell", { row: 9, column: 9, number: 9 }

        expect(last_response).to be_not_found
        expect(last_response.json).to eq({ 'error' => 'game not found' })
      end
    end
  end
end
