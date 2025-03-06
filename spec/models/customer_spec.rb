require "rails_helper"

RSpec.describe Customer do
  it { is_expected.to have_many :invoices }
end
