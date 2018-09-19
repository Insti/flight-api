require './app/flight_query'
require './lib/flight_storage'
require './lib/scraper'

def most_recent_flight_data_filename
  Dir.glob('database/*').max_by { |f| File.mtime(f) }
end

FlightQuery.set :storage, FlightStorage.new(filename: most_recent_flight_data_filename)
FlightQuery.set :scraper, Scraper
run FlightQuery
