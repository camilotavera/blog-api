require 'rails_helper'

RSpec.describe "Healths", type: :request do
describe 'Get /health' do
    before { get '/health' }

    it 'return ok' do
      payload = JSON.parse(response.body)
      expect(payload).not_to be_empty
      expect(payload['api']).to eq('OK')
    end

    it 'return status code 200' do
      expect(response).to have_http_status(200)
    end
  end
end
