class Api::V1::Merchants::CouponsController < ApplicationController
  rescue_from ActionController::ParameterMissing do |e|
    render json: ErrorSerializer.format_errors([e.message]), status: :unprocessable_entity
  end

  def index
    merchant = Merchant.find(params[:merchant_id])
    coupons = merchant.coupons
    if params[:active] && ["true", "false"].include?(params[:active].downcase)
      coupons = coupons.active_filter(params[:active].downcase)
    end
    render json: CouponSerializer.new(coupons)
  end

  def show
    merchant = Merchant.find(params[:merchant_id])
    render json: CouponSerializer.new(merchant.coupons.find(params[:id]))
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    if max_active_coupons(merchant)
      render json: ErrorSerializer.too_many_active_coupons_response, status: :bad_request
      return
    end
    coupon = merchant.coupons.create!(create_params) # safe to use create! here because our exception handler will gracefully handle exception
    render json: CouponSerializer.new(coupon), status: :created
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    coupon = merchant.coupons.find(params[:id])
    if update_params[:active] == true && max_active_coupons(merchant)
      render json: ErrorSerializer.too_many_active_coupons_response, status: :bad_request
      return
    elsif update_params[:active] == false && pending_invoices?(coupon)
      render json: ErrorSerializer.pending_invoices_response, status: :bad_request
      return
    end
    coupon.update!(update_params)
    render json: CouponSerializer.new(coupon)
  end

  private

  def create_params
    params
      .require(:coupon)
      .permit(:name, :code, :discount_type, :value)
      .with_defaults(active: true)
  end

  def update_params
    params
      .require(:coupon)
      .permit(:name, :code, :discount_type, :value, :active)
  end

  def max_active_coupons(merchant)
    merchant.coupons.active_filter(true).length >= 5
  end

  def pending_invoices?(coupon)
    coupon.invoices.where(status: "packaged").length > 0
  end
end
