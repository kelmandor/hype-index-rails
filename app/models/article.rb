class Article < ApplicationRecord
  belongs_to :text_source
  # belongs_to :time_object, optional: true
  has_one_attached :content
  has_one_attached :html

  has_many :article_assets, dependent: :destroy
  has_many :assets, through: :article_assets

  # after_create :scrape_and_match
  @@asset_hash ||= Asset.build_hash

  def scrape_bg
    ArticleScrapeWorker.perform_async(self.id)
  end

  def scrape
    begin
      if !self.html.attached? || !self.content.attached?
        data = Nlp.extract_text(self.url)
        store_content(data)
        store_html(data)
      end
    rescue
      puts '$$$$$$$$$$$$$ BAD SCRAPE $$$$$$$$$$$$$'
    end
  end

  def store_html(data)
    filename = "#{self.url.gsub(/[^0-9a-z ]/i, '')}.html.txt"

    obj = {
      io: StringIO.new(data['html']),
      filename: filename,
      content_type: 'text/plain'
    }
    self.html.attach(obj)
  end

  def store_content(data)
    filename = "#{self.url.gsub(/[^0-9a-z ]/i, '')}.txt"
    txt = StringIO.new(data['sentences'].join("\n"))
    obj = {
      io: txt,
      filename: filename,
      content_type: 'text/plain'
    }
    self.content.attach(obj)
  end

  def console_print_content
    if self.content.attached?
      cnt = self.content.download
      cnt.each_line{|l| puts l}
    else
      puts 'no content attached :('
    end
  end

  def match_assets(to_save = false)
    puts "starting match_assets"
    t0 = Time.now
    txt = self.content.download

    combined = @@asset_hash.keys.compact.map{|a| a.gsub(/[^0-9a-z ]/i, '')}.join('|')
    puts "scanning the text"
    matched = txt.scan(/(#{combined})/).flatten.uniq
    t4=Time.now
    puts "scanning the text. Took: #{t4-t0} s"

    puts "cycling through matches"
    asts = []
    matched.each do |a|
      ass = @@asset_hash[a]
      # puts "ARTICLE #{self.id} MATCHES #{a}"
      if ass
        # self.assets << ass unless self.assets.include?(ass)
        asts << ass # unless self.assets.include?(ass)
      end
    end
    self.assets = asts.uniq

    t5=Time.now
    puts "cycling through matches. Took: #{t5-t4} s"
    self.scanned_for_assets = true
    puts "END match_assets Took: #{t5-t0} s"
    self.save! if to_save
  end

  def self.scrape_and_match
    all.each do |a|
      a.scrape_and_match
    end
  end

  def scrape_and_match
    self.scrape
    while !self.content.attached? # i dont think this really works
      sleep 2
    end

    self.match_assets rescue puts "@@@@@@@@ match failed article id #{self.id}"
  end

  def scrape_time(to_save = false)
    begin
      page = Nokogiri::HTML(self.html.download)
      tm = self.text_source.scraper_object.scrape_time(page)
      ts = tm.to_i
      self.datetime = tm
      self.timestamp = ts
      self.save! if to_save
      # self.time_object
    rescue
      puts "scrapetime failed article id: #{self.id}"
    end
  end

  def scrape_headline(to_save = false)
    page = Nokogiri::HTML(self.html.download)
    self.headline = self.text_source.scraper_object.scrape_headline(page)
    self.save! if to_save
    self.headline
  end

  def scrape_and_save
    self.match_assets
    self.scrape_time
    self.scrape_headline
    self.save!
  end

  def self.agg_asset_mentions
    'doriscool'
  end

  def by_date
    datetime.to_date.to_s(:db)
  end

  def by_week
    datetime.beginning_of_week.to_date.to_s(:db)
  end

end
