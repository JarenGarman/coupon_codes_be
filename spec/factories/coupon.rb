FactoryBot.define do
  factory :customer do
    name { Faker::Commerce.promotion_code(digits: 2) }
    code { Faker::Commerce.unique.promotion_code }
    type { ["percent", "flat"].sample }
    value { Faker::Commerce.price(range: 0..99.99) }
  end
end
