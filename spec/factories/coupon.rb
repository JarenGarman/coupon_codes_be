FactoryBot.define do
  factory :coupon do
    name { Faker::Commerce.promotion_code(digits: 2) }
    code { Faker::Commerce.unique.promotion_code }
    discount_type { ["percent", "flat"].sample }
    value { Faker::Commerce.price(range: 0.01..99.99) }
    active? { true }
    merchant
  end
end
