class PaymentIntent

  def self.create(amount: Order::UNIT_PRICE_CENTS, currency: Order::CURRENCY)
    self.set_secret_key

    Stripe::PaymentIntent.create({
      amount: amount,
      currency: currency,
    })
  end

  def self.find(id)
    self.set_secret_key
    
    Stripe::PaymentIntent.retrieve(id)
  end

  private
    def self.set_secret_key
      Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
    end
end