class Article < ApplicationRecord
  belongs_to :text_source
  has_one_attached :content
  # def
end
