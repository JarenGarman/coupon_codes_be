class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :value, :active?
  attributes :use_count do |coupon|
    coupon.invoices.length
  end
end
