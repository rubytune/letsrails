class DealsController < ApplicationController
  def index
    @deals = current_city.deals.shuffle
  end

  def show
    @deal = Deal.find(params[:id])
  end
end
