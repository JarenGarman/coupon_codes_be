require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
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
        expect(coupon[:attributes][:use_count]).to eq(0)
      end
    end
  end

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

  describe "create" do
    it "returns 201 with coupon for successful creation" do
      merchant = create(:merchant)
      coupon_params = {
        name: Faker::Commerce.promotion_code(digits: 2),
        code: Faker::Commerce.unique.promotion_code,
        discount_type: ["percent", "flat"].sample,
        value: Faker::Commerce.price(range: 0.01..99.99)
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:created)
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to be_a(String)
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes]).to include(
        name: coupon_params[:name],
        code: coupon_params[:code],
        discount_type: coupon_params[:discount_type],
        value: coupon_params[:value],
        active?: true
      )
    end

    it "returns 404 with error message when merchant is not found" do
      coupon_params = {
        name: Faker::Commerce.promotion_code(digits: 2),
        code: Faker::Commerce.unique.promotion_code,
        discount_type: ["percent", "flat"].sample,
        value: Faker::Commerce.price(range: 0.01..99.99)
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants/100000/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
    end

    it "returns 400 with error message when merchant has 5 active coupons" do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant)
      coupon_params = {
        name: Faker::Commerce.promotion_code(digits: 2),
        code: Faker::Commerce.unique.promotion_code,
        discount_type: ["percent", "flat"].sample,
        value: Faker::Commerce.price(range: 0.01..99.99)
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("This merchant already has 5 active coupons")
    end

    it "returns 400 with error message when code is not unique" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      coupon_params = {
        name: Faker::Commerce.promotion_code(digits: 2),
        code: coupon.code,
        discount_type: ["percent", "flat"].sample,
        value: Faker::Commerce.price(range: 0.01..99.99)
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Validation failed: Code has already been taken")
    end

    it "returns 400 with error message when params not provided" do
      merchant = create(:merchant)
      coupon_params = {
        name: Faker::Commerce.promotion_code(digits: 2),
        code: Faker::Commerce.unique.promotion_code,
        discount_type: ["percent", "flat"].sample
      }
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/merchants/#{merchant.id}/coupons", headers: headers, params: JSON.generate(coupon: coupon_params)

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Validation failed: Value can't be blank, Value is not a number")
    end
  end

  describe "update" do
    it "can deactivate a coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", headers: headers, params: JSON.generate(coupon: {active?: false})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to be_a(String)
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes]).to include(
        name: coupon.name,
        code: coupon.code,
        discount_type: coupon.discount_type,
        value: coupon.value,
        active?: false
      )
    end

    it "can activate a coupon" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant, active?: false)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", headers: headers, params: JSON.generate(coupon: {active?: true})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(json[:data]).to be_a(Hash)
      expect(json[:data][:id]).to be_a(String)
      expect(json[:data][:type]).to eq("coupon")
      expect(json[:data][:attributes]).to include(
        name: coupon.name,
        code: coupon.code,
        discount_type: coupon.discount_type,
        value: coupon.value,
        active?: true
      )
    end

    it "returns 400 with error message when merchant has 5 active coupons" do
      merchant = create(:merchant)
      create_list(:coupon, 5, merchant: merchant)
      coupon = create(:coupon, merchant: merchant, active?: false)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", headers: headers, params: JSON.generate(coupon: {active?: true})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("This merchant already has 5 active coupons")
    end

    it "returns 404 and error message when merchant is not found" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/100000/coupons/#{coupon.id}", headers: headers, params: JSON.generate(coupon: {active?: false})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Merchant with 'id'=100000")
    end

    it "returns 404 and error message when coupon is not found" do
      merchant = create(:merchant)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}/coupons/0", headers: headers, params: JSON.generate(coupon: {active?: false})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:not_found)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Couldn't find Coupon with 'id'=0 [WHERE \"coupons\".\"merchant_id\" = $1]")
    end

    it "returns 422 and error message when params not provided" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", headers: headers, params: JSON.generate(coupon: {})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Validation failed: Active? can't be blank")
    end

    it "returns 400 and error message when deactivating coupon with pending invoices" do
      merchant = create(:merchant)
      coupon = create(:coupon, merchant: merchant)
      create(:invoice, status: "packaged", merchant: merchant, coupon: coupon)
      headers = {"CONTENT_TYPE" => "application/json"}

      patch "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}", headers: headers, params: JSON.generate(coupon: {active?: false})

      json = JSON.parse(response.body, symbolize_names: true)

      expect(response).to have_http_status(:bad_request)
      expect(json[:message]).to eq("Your query could not be completed")
      expect(json[:errors]).to be_a Array
      expect(json[:errors].first).to eq("Cannot deactivate coupon with pending invoices")
    end
  end
end
