class StudyController < ApplicationController
  def index
    @aa = ArticleAsset.includes(:asset, article: {content_attachment: :blob})
  end
end