class FlightStorage
  def initialize(filename:)
    @filename = filename
  end

  def flight_data
    @flight_data ||= load_data
  end

  def size
    flight_data.size
  end

  def search(field, term = nil)
    if field == 'all'
      search_all(term)
    else
      search_field(field, term)
    end
  end

  def search_not(field, term = nil)
    flight_data - search(field, term)
  end

  def search_field(field, term)
    if term.nil?
      flight_data.reject { |flight| flight[field.to_sym] == '' }
    else
      flight_data.select { |flight| flight[field.to_sym] =~ /#{term}/i }
    end
  end

  def search_all(term)
    flight_data.select do |flight|
      flight.values.any? { |value| value =~ /#{term}/i }
    end
  end

  def load_data
    raw_data = File.read(@filename)
    JSON.parse(raw_data, symbolize_names: true)
  end
end
