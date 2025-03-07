class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :value, :active?, :merchant_id, :use_count
end
