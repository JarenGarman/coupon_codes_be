require "rails_helper"

describe Coupon, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_presence_of :type }
    it { is_expected.to validate_presence_of :value }
  end

  describe "relationships" do
    it { is_expected.to belong_to :merchant }
  end
end
