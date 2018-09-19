require 'spec_helper.rb'

describe Scraper do
  let(:fake_time) { Time.at(123_456_789) }
  subject { Scraper.new(current_time: fake_time) }

  context '#download' do
    it 'downloads the data to a local file' do
      # We don't need to care about the result
      FileUtils.cp('spec/fixtures/arrivals.html','cache/ankomster.html')
      FileUtils.cp('spec/fixtures/departures.html','cache/afgange.html')

      expect(File).to receive(:write)
      expect(subject.download).to eq 'database/123456789.flight_data.json'
    end

    # This is a bit horrible
    it 'downloads when there is no cache' do
      # Stub out writes
      allow(File).to receive(:write)

      # Pretend the cache files don't exist
      expect(File).to receive(:exist?).with('cache/ankomster.html').and_return(false)
      expect(File).to receive(:exist?).with('cache/afgange.html').and_return(false)

      # We don't need to care about the result
      fake_file = double('file', read: '')
      expect(OpenURI).to receive(:open_uri).exactly(2).times.and_return(fake_file)

      expect(subject.download).to eq 'database/123456789.flight_data.json'
    end
  end

  context '.clear_cache' do
    it 'clears the cache files' do
      expect(File).to receive(:exist?).with('cache/ankomster.html').and_return(true)
      expect(File).to receive(:exist?).with('cache/afgange.html').and_return(true)
      expect(File).to receive(:delete).with('cache/ankomster.html')
      expect(File).to receive(:delete).with('cache/afgange.html')
      Scraper.clear_cache
    end
  end
end
