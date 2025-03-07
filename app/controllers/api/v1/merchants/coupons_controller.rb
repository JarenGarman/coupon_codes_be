class Api::V1::Merchants::CouponsController < ApplicationController
  def index
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(merchant.coupons.with_use_count)
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(merchant.coupons.with_use_count.find(params[:id]))
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    if active_merchant_coupons(merchant) >= 5
      render json: ErrorSerializer.too_many_active_coupons_response, status: :bad_request
      return
    end
    coupon = merchant.coupons.create!(coupon_params) # safe to use create! here because our exception handler will gracefully handle exception
    render json: CouponSerializer.new(coupon), status: :created
  end

  private

  def coupon_params
    params
      .require(:coupon)
      .permit(:name, :code, :discount_type, :value)
      .with_defaults(active?: true)
  end

  def active_merchant_coupons(merchant)
    merchant.coupons.count do |coupon|
      coupon.active?
    end
  end
end
