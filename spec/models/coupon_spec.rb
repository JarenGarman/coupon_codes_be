require "rails_helper"

describe Coupon, type: :model do
  describe "validations" do
    before do
      create(:coupon)
    end

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_uniqueness_of :code }
    it { is_expected.to validate_presence_of :discount_type }
    it { is_expected.to validate_inclusion_of(:discount_type).in_array(["percent", "flat"]) }
    it { is_expected.to validate_presence_of :value }
    it { is_expected.to validate_numericality_of :value }
    it { is_expected.to validate_presence_of :active? }
    it { is_expected.to validate_inclusion_of(:active?).in_array([true, false]) }
    it { is_expected.to validate_presence_of :use_count }
    it { is_expected.to validate_numericality_of :use_count }
  end

  describe "relationships" do
    it { is_expected.to belong_to :merchant }
    it { is_expected.to have_many :invoices }
  end
end
