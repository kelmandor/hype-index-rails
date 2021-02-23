class FrontendController < ApplicationController
  def index
    return render json: Asset.find(1).serve_graph_data
    # return render plain: TimeObject.serve_csv
  end

  def assets_list
    return render json: Asset.serve_list
  end

  def asset
    ast_id = params[:id]
    ast = Asset.find(ast_id)
    return render json: ast.serve_graph_data
  end
end
