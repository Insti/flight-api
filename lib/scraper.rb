require 'nokogiri'
require 'open-uri'
require_relative 'parser'

# Fetches and parses the flight data
class Scraper
  URLS = {
    arrivals: 'https://www.cph.dk/flyinformation/ankomster',
    departures: 'https://www.cph.dk/flyinformation/afgange'
  }.freeze

  CACHE = {
    arrivals: 'cache/ankomster.html',
    departures: 'cache/afgange.html'
  }.freeze

  def self.clear_cache
    CACHE.values.each { |file| File.delete(file) if File.exist?(file) }
  end

  attr_reader :current_time
  def initialize(current_time:)
    @current_time = current_time
  end

  def download
    result = (arrivals + departures)
    File.write(filename, result.to_json)
    filename
  end

  private

  def arrivals
    raw_html = fetch_or_read(URLS[:arrivals], CACHE[:arrivals])
    Parser::Arrivals.new(html: raw_html, timestamp: timestamp, flight_date: date).call
  end

  def departures
    raw_html = fetch_or_read(URLS[:departures], CACHE[:departures])
    Parser::Departures.new(html: raw_html, timestamp: timestamp, flight_date: date).call
  end

  def date
    current_time.strftime('%Y%m%d')
  end

  def timestamp
    current_time.to_i
  end

  def filename
    "database/#{timestamp}.flight_data.json"
  end

  def fetch_or_read(url, filename)
    if File.exist?(filename)
      File.read(filename)
    else
      data = open(url).read
      File.write(filename, data)
      data
    end
  end
end
