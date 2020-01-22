require 'spec_helper'
require 'sudoku/grid'
require 'sudoku/matrices'

RSpec.describe 'note number manipulation' do
  include JSONRequests

  let( :grid   ) { Sudoku::Matrices::TEST_MATRIX                                               }
  let!(:game_id) { post_json('/games', { grid: grid }).then { |response| response.json['id'] } }

  it 'fills notes correctly' do
    patch_json "/games/#{game_id}/add_note", { row: 9, column: 9, number: 1 }
    patch_json "/games/#{game_id}/add_note", { row: 9, column: 9, number: 9 }
    patch_json "/games/#{game_id}/add_note", { row: 9, column: 9, number: 9 }

    expect(last_response                         ).to be_ok
    expect(last_response.json['notes_grid'][8][8]).to eq [1, 9]
  end

  it 'validates input correctly' do
    patch_json "/games/#{game_id}/add_note", { row: 0, column: 10, number: 4.5 }

    expect(last_response               ).to be_bad_request
    expect(last_response.json['row']   ).to eq ['must be greater than or equal to 1']
    expect(last_response.json['column']).to eq ['must be less than or equal to 9'   ]
    expect(last_response.json['number']).to eq ['must be an integer'                ]
  end

  it 'refuses to add note to filled cell' do
    patch_json "/games/#{game_id}/add_note", { row: 1, column: 1, number: 1 }

    expect(last_response              ).to be_bad_request
    expect(last_response.json['error']).to eq 'cell (1, 1) is already filled'
  end
end
