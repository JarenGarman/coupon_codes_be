class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  attribute :item_count, if: proc { |merchant, params|
    params && params[:count] == true
  } do |merchant|
    merchant.item_count
  end

  attributes :coupons_count do |merchant|
    merchant.coupons.length
  end

  attributes :invoice_coupon_count do |merchant|
    merchant.invoices.count do |invoice|
      invoice.coupon_id
    end
  end
end
