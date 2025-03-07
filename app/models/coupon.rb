class Coupon < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true, inclusion: {in: ["percent", "flat"]}
  validates :value, presence: true, numericality: true
  validates :active?, presence: true, inclusion: [true, false]
  validates :use_count, presence: true, numericality: true
  belongs_to :merchant
  has_many :invoices
end
