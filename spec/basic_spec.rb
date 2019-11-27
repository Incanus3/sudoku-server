require 'spec_helper'

RSpec.describe do # rubocop:disable Metrics/BlockLength
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
end
