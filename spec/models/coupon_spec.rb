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
    it { is_expected.to validate_inclusion_of(:active).in_array([true, false]) }
  end

  describe "relationships" do
    it { is_expected.to belong_to :merchant }
    it { is_expected.to have_many :invoices }
  end

  describe "class methods" do
    it ".active_filter" do
      create_list(:coupon, 10, active: false)
      create_list(:coupon, 5)

      expect(Coupon.active_filter("true").length).to eq(5)
      expect(Coupon.active_filter("false").length).to eq(10)
    end
  end
end
