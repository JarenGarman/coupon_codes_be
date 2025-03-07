class CouponSerializer
  include JSONAPI::Serializer
  attributes :name, :code, :discount_type, :value, :active?, :use_count
end
