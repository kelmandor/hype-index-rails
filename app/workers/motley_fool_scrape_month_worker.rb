class MotleyFoolScrapeMonthWorker
  include Sidekiq::Worker
  sidekiq_options queue: :important

  def perform(text_source_id, date_str)
    puts 'waiting a bit..'
    sleep 30
    puts 'OK, lets go!'
    date = DateTime.parse(date_str)
    ts = TextSource.find(text_source_id)
    MotleyFoolScraper.scrape_for_month(ts, date)
  end
end
