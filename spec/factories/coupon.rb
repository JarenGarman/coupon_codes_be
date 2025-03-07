FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code(digits: 2) }
    code { Faker::Commerce.unique.promotion_code }
    discount_type { ["percent", "flat"].sample }
    value { Faker::Commerce.price(range: 0..99.99) }
    active? { true }
    use_count { 0 }
    merchant
  end
end
