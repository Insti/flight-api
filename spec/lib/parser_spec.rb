require 'spec_helper.rb'

describe Parser do
  let(:fake_timestamp) { 123_456_789 }
  let(:fake_date) { '17/09/2018' }

  context '#arrivals' do
    it 'parses the arrivals data' do
      raw_html = File.read('spec/fixtures/arrivals.html')
      subject = Parser::Arrivals.new(html: raw_html, timestamp: fake_timestamp, flight_date: fake_date)
      result = subject.call
      expect(result.size).to eq 297
    end

    it 'ignores headings' do
      raw_html = File.read('spec/fixtures/arrival_headings.html')
      subject = Parser::Arrivals.new(html: raw_html, timestamp: fake_timestamp, flight_date: fake_date)
      expect(subject.call).to eq []
    end

    it 'copes with delayed arrivals' do
      raw_html = File.read('spec/fixtures/arrival_delayed.html')
      subject = Parser::Arrivals.new(html: raw_html, timestamp: fake_timestamp, flight_date: fake_date)
      expect(subject.call).to eq [
        {
          timestamp: fake_timestamp,
          date: fake_date,
          time: '06:30',
          expected: '16:44',
          airline: 'Cathay Pacific',
          flight_number: 'CX227',
          source: 'Hong Kong',
          destination: 'Copenhagen',
          terminal: '',
          status: '',
          gate: ''
        }
      ]
    end

    it 'copes with landed arrivals' do
      raw_html = File.read('spec/fixtures/arrival_landed.html')
      subject = Parser::Arrivals.new(html: raw_html, timestamp: fake_timestamp, flight_date: fake_date)
      expect(subject.call).to eq [
        {
          timestamp: fake_timestamp,
          date: fake_date,
          time: '11:10',
          expected: '11:13',
          airline: 'SAS',
          flight_number: 'SK752',
          source: 'Warsaw',
          destination: 'Copenhagen',
          terminal: '',
          status: 'Landed',
          gate: 'A4'
        }
      ]
    end
  end

  context 'Departures#call' do
    it 'parses all the departures data' do
      raw_html = File.read('spec/fixtures/departures.html')
      subject = Parser::Departures.new(html: raw_html, timestamp: fake_timestamp, flight_date: fake_date)
      expect(subject.call.size).to eq 267
    end

    it 'deals with standard departures' do
      raw_html = File.read('spec/fixtures/departure_standard.html')
      subject = Parser::Departures.new(html: raw_html, timestamp: fake_timestamp, flight_date: fake_date)
      expect(subject.call).to eq(
        [
          {
            timestamp: fake_timestamp,
            date: fake_date,
            time: '11:20',
            expected: '',
            airline: 'Vueling',
            flight_number: 'VY1877',
            source: 'Copenhagen',
            destination: 'Malaga',
            terminal: '',
            status: 'Closed',
            gate: 'A21'
          }
        ]
      )
    end
  end
end
