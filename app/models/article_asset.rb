class ArticleAsset < ApplicationRecord
  belongs_to :article
  belongs_to :asset

  def console_show_match
    puts "######### CONTENT #########"
    self.article.console_print_content
    puts "######### ASSET #########"
    puts "name: #{self.asset.name} | symbol: #{self.asset.symbol}"
  end
end
