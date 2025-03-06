class Coupon < ApplicationRecord
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :type, presence: true
  validates :value, presence: true, numericality: true
  belongs_to :merchant
  has_many :invoices
end
