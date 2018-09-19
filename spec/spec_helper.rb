require 'simplecov'
SimpleCov.start do
  add_filter 'vendor'
  add_filter 'spec'
end

require './app/flight_query'
require './lib/scraper'
require './lib/flight_storage'
