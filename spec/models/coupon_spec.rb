require "rails_helper"

describe Coupon, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_uniqueness_of :code }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :value }
    it { is_expected.to validate_numericality_of :value }
  end

  describe "relationships" do
    it { is_expected.to belong_to :merchant }
    it { is_expected.to have_many :invoices }
  end
end
