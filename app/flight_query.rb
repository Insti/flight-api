require 'sinatra/base'
require 'json'

class FlightQuery < Sinatra::Base
  def flight_storage
    settings.storage
  end

  def flight_scraper
    settings.scraper
  end

  get '/' do
    erb :index
  end

  get '/search/not/:field/?:term?' do |field, term|
    content_type 'application/json'
    flight_storage.search_not(field, term).to_json
  end

  get '/search/:field/?:term?' do |field, term|
    content_type 'application/json'
    flight_storage.search(field, term).to_json
  end

  get '/scrape' do
    scrape_flights
    count = flight_storage.size
    "scraped #{count} flights"
  end

  def scrape_flights
    flight_scraper.clear_cache
    filename = flight_scraper.new(current_time: Time.now).download
    settings.storage = flight_storage.class.new(filename: filename)
  end
end
