require 'spec_helper.rb'
require 'rack/test'

describe 'The Flight Query App' do
  include Rack::Test::Methods

  def app
    # TODO: tests should use mock storage
    test_storage = FlightStorage.new(filename: 'spec/fixtures/database/test_flights.json')
    mock_scraper_instance = double(Scraper, download: 'spec/fixtures/database/test_flights.json')
    mock_scraper_class = double(Scraper, clear_cache: true, new: mock_scraper_instance)
    FlightQuery.set :storage, test_storage
    FlightQuery.set :scraper, mock_scraper_class
    FlightQuery
  end

  it 'has some flight info' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to match('Some flight info')
  end

  it 'triggers scraping' do
    get '/scrape'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('scraped 564 flights')
  end

  context 'search' do
    it 'specific fields' do
      get '/search/status/Landed'
      expect(last_response).to be_ok
      expect(last_response.content_type).to eq 'application/json'
      expect(last_response.body).to match(/\[{"airline":"SAS"[^}]*"status":"Landed"/)
    end

    it 'specific time' do
      get '/search/time/11:00'
      expect(last_response).to be_ok
      expect(last_response.body).to match(/\[{"airline":"SAS"/)
    end

    it 'non-empty fields if no parameter' do
      get '/search/gate/'
      expect(last_response.body).to match(/\[{"airline":"Danish Air Transport"[^}]*"gate":"A11"/)
    end

    it 'non-empty fields without trailing slash' do
      get '/search/gate'
      expect(last_response.body).to match(/\[{"airline":"Danish Air Transport"[^}]*"gate":"A11"/)
    end

    it 'searches all fields' do
      get '/search/all/Landed'
      expect(last_response).to be_ok
      expect(last_response.content_type).to eq 'application/json'
      expect(last_response.body).to match(/\[{"airline":"SAS"[^}]*"status":"Landed"/)
    end

    it 'can return everything' do
      get '/search/all'
      expect(last_response).to be_ok
      expect(last_response.content_type).to eq 'application/json'
      expect(last_response.body).to match(/\[{"airline":"Cathay Pacific"/)
    end

    it 'can invert with not' do
      get '/search/not/all'
      expect(last_response).to be_ok
      expect(last_response.content_type).to eq 'application/json'
      expect(last_response.body).to match(/\[\]/)
    end

    it 'non-empty fields without trailing slash' do
      get '/search/not/gate'
      expect(last_response.body).to match(/\[{"airline":"Cathay Pacific"[^}]*"gate":""/)
    end
  end
end
