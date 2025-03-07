class Coupon < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :discount_type, presence: true, inclusion: ["percent", "flat"]
  validates :value, presence: true, numericality: true
  validates :active, inclusion: [true, false]
  belongs_to :merchant
  has_many :invoices

  def self.active_filter(active_param)
    where(active: ActiveModel::Type::Boolean.new.cast(active_param))
  end
end
