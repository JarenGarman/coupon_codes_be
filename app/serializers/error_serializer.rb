class ErrorSerializer
  def self.format_errors(messages)
    {
      message: "Your query could not be completed",
      errors: messages
    }
  end

  def self.format_invalid_search_response
    {
      message: "your query could not be completed",
      errors: ["invalid search params"]
    }
  end

  def self.too_many_active_coupons_response
    {
      message: "Your query could not be completed",
      errors: ["This merchant already has 5 active coupons"]
    }
  end

  def self.pending_invoices_response
    {
      message: "Your query could not be completed",
      errors: ["Cannot deactivate coupon with pending invoices"]
    }
  end
end
