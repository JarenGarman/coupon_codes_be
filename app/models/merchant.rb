class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :items, dependent: :destroy
  has_many :invoices, dependent: :destroy
  has_many :customers, through: :invoices
  has_many :coupons

  def self.sorted_by_creation
    Merchant.order("created_at DESC")
  end

  def self.filter_by_status(status)
    joins(:invoices).where(invoices: {status: status}).select("distinct merchants.*")
  end

  def item_count
    items.count
  end

  def distinct_customers
    Customer
      .joins(invoices: :merchant)
      .where(merchants: {id: id})
      .distinct
  end

  def invoices_filtered_by_status(status)
    invoices.where(status: status)
  end

  def self.find_all_by_name(name)
    Merchant.where("name iLIKE ?", "%#{name}%")
  end

  def self.find_one_merchant_by_name(name)
    Merchant.find_all_by_name(name).order("LOWER(name)").first
  end
end
