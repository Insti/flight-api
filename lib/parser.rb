class Parser
  attr_reader :html, :timestamp, :date

  def initialize(html:, flight_date:, timestamp:)
    @html = html.freeze
    @timestamp = timestamp
    @date = flight_date
  end

  class Arrivals < Parser
    def names
      { time: 0, expected: 1, airline: 2, source: 3, gate: 4,
        terminal: 5, status: 6, flight_number: 3,
        destination: nil, timestamp: nil, date: nil }.sort
    end

    def parse_destination(_)
      'Copenhagen'
    end
  end

  class Departures < Parser
    def names
      # Format is: {name: column}
      # name: key of our final data
      # column: column index from source data
      { time: 0, expected: 1, airline: 2, destination: 3, gate: 4,
        terminal: 5, status: 6, flight_number: 3,
        source: nil, timestamp: nil, date: nil }.sort
    end

    def parse_source(_)
      'Copenhagen'
    end
  end

  def call
    ignore_headers(flight_data)
  end

  private

  def flight_data
    rows.map { |row| extract_data(names, row) }
  end

  def extract_data(names, row)
    columns = columns(row)
    names.map do |name, index|
      value = send("parse_#{name}", cell_data(columns, index))
      [name, value]
    end.to_h
  end

  def ignore_headers(flight_data)
    flight_data.select { |data| data[:time] =~ /\d\d:\d\d/ }
  end

  ## HTML parsing stuff
  def page
    Nokogiri::HTML(html)
  end

  def rows
    page.css('.stylish-table__row')
  end

  def columns(row)
    row.css('.stylish-table__cell')
  end

  def null_cell
    Nokogiri::XML::Node.new('null', Nokogiri.make('null'))
  end

  # TODO: Could be an object or array method on cells
  def cell_data(cells, index)
    cell = cells[index] unless index.nil?
    (cell || null_cell).css('div/span')
  end

  # Element Parsers below here
  # These should be classes, but methods keep it simpler for now.

  def parse_time(elements)
    elements.first.text
  end

  def parse_expected(element)
    element.text
  end

  def parse_airline(element)
    element.text
  end

  def parse_source(elements)
    elements.first.text
  end

  def parse_destination(elements)
    elements.first.text
  end

  def parse_flight_number(elements)
    elements.last.text
  end

  def parse_gate(element)
    element.text
  end

  def parse_terminal(element)
    element.text
  end

  def parse_status(element)
    element.text
  end

  def parse_timestamp(_)
    timestamp
  end

  def parse_date(_)
    date
  end
end
