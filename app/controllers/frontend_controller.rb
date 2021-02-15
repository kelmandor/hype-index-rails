class FrontendController < ApplicationController
  def index
    return render json: TimeObject.serve_data
    # return render plain: TimeObject.serve_csv
  end
end
