class Api::V1::Merchants::CouponsController < ApplicationController
  def show
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(merchant.coupons.with_use_count.find(params[:id]))
  end
end
