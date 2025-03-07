require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
  describe "show" do
    it "returns a coupon for a given merchant" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      create_list(:coupon, 10)

      get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to eq(coupon.id.to_s)
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes]).to include(
        name: coupon.name,
        code: coupon.code,
        discount_type: coupon.discount_type,
        value: coupon.value,
        active?: coupon.active?,
        use_count: 0
      )
    end

    it "returns 404 and error message when merchant is not found" do
      get "/api/v1/merchants/100000/coupons/0"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
    end

    it "returns 404 and error message when coupon is not found" do
      merchant = create(:merchant)

      get "/api/v1/merchants/#{merchant.id}/coupons/0"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Coupon with 'id'=0 [WHERE \"coupons\".\"merchant_id\" = $1]")
    end
  end

  describe "index" do
    it "returns all coupons for merchant" do
      merchant = create(:merchant)
      create_list(:coupon, 10, active?: false, merchant: merchant)
      create_list(:coupon, 5, merchant: merchant)

      get "/api/v1/merchants/#{merchant.id}/coupons"

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_an(Array)
      expect(json[:data].length).to eq(15)
      json[:data].each do |coupon|
        expect(coupon[:id]).to be_a(String)
        expect(coupon[:type]).to eq("coupon")
        expect(coupon[:attributes][:name]).to be_a(String)
        expect(coupon[:attributes][:code]).to be_a(String)
        expect(coupon[:attributes][:discount_type]).to eq("percent").or eq("flat")
        expect(coupon[:attributes][:value]).to be_a(Float)
        expect(coupon[:attributes][:active?]).to be(true).or be(false)
      end
    end
  end
end
