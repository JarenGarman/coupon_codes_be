class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :value, :active?
  attributes :use_count, if: proc { |coupon| coupon[:use_count] }
end
