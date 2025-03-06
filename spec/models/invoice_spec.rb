require "rails_helper"

RSpec.describe Invoice do
  it { is_expected.to belong_to :merchant }
  it { is_expected.to belong_to :customer }
  it { is_expected.to belong_to(:coupon).optional }
  it { is_expected.to validate_inclusion_of(:status).in_array(%w[shipped packaged returned]) }
end
