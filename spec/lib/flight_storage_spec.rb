require 'spec_helper.rb'

describe FlightStorage do
  let(:test_filename) { 'spec/fixtures/database/test_flights.json' }
  let(:test_data_size) { 564 }
  subject { FlightStorage.new(filename: test_filename) }

  it 'can be built' do
    expect(subject).not_to be_nil
  end

  context '#flight_data' do
    it 'has flight data' do
      expect(subject.flight_data.size).to be test_data_size
    end
  end

  context '#size' do
    it 'size is the size of the flight data' do
      expect(subject.size).to be test_data_size
    end
  end

  context '#search' do
    it 'can be searched for everything' do
      expect(subject.search('all').size).to be test_data_size
    end

    it 'can be searched for specific statuses' do
      result = subject.search('status', 'Landed')
      expect(result.size).to be 11
      expect(result).to all(satisfy { |h| h[:status] == 'Landed' })
    end

    it 'can be searched for specific statuses case insensitively' do
      result = subject.search('status', 'lANDed')
      expect(result.size).to be 11
      expect(result).to all(satisfy { |h| h[:status] == 'Landed' })
    end

    it 'can be searched for non-empty statuses' do
      expect(subject.search('status', 'landed').size).to be 11
      expect(subject.search('status', nil)).to all(satisfy { |h| h[:status] != '' })
    end

    it 'all is case insensitve too' do
      result = subject.search('all', 'mid')
      expect(result.size).to be 9
      expect(result).to all(satisfy { |h| h.values.any? { |v| v =~ /mid/i } })
    end
  end

  context '#search_not' do
    it 'can negate a search' do
      result = subject.search_not('status', 'lANDed')
      expect(result.size).to be test_data_size - 11
      expect(result).to all(satisfy { |h| h[:status] != 'Landed' })
    end

    it 'opposite of everything is nothing' do
      result = subject.search_not('all')
      expect(result.size).to be 0
    end
  end
end
