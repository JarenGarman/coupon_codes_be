class Coupon < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true, inclusion: {in: ["percent", "flat"]}
  validates :value, presence: true, numericality: true
  validates :active?, presence: true, inclusion: [true, false]
  belongs_to :merchant
  has_many :invoices

  def self.with_use_count
    left_joins(:invoices)
      .select("coupons.*, COUNT(invoices.id) AS use_count")
      .group("coupons.id")
  end
end
