class PurchasesController < ApplicationController

  before_filter :load_deal

  def new
    @purchase = Purchase.new
  end

protected
  def load_deal
    @deal = Deal.find(params[:deal_id])
  end
end
