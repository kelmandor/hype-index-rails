class Article < ApplicationRecord
  belongs_to :text_source
  has_one_attached :content
  has_one_attached :html

  after_create :scrape

  def scrape
    if !self.html.attached? || !self.content.attached?
      data = Nlp.extract_text(self.url)
      store_content(data)
      store_html(data)
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
end
