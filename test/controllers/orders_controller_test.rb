require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get orders_url, headers: { 'HTTP_AUTHORIZATION' => authorization }
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    mock = Minitest::Mock.new
    def mock.status
      'succeeded'
    end

    Stripe::PaymentIntent.stub :retrieve, mock do
      assert_difference('Order.count') do
        post orders_url, params: { order: { amount_cents: @order.amount_cents, country: @order.country, email_address: @order.email_address, first_name: @order.first_name, last_name: @order.last_name, number: @order.number, postal_code: @order.postal_code } }
      end
    end

    assert_redirected_to order_permalink_url(Order.last.permalink)
  end

  test "should not create order if payment did not succeed" do
    mock = Minitest::Mock.new
    def mock.status
      'not yet paid'
    end

    Stripe::PaymentIntent.stub :retrieve, mock do
      err = assert_raises(RuntimeError) do
        post orders_url, params: { order: { amount_cents: @order.amount_cents, country: @order.country, email_address: @order.email_address, first_name: @order.first_name, last_name: @order.last_name, number: @order.number, postal_code: @order.postal_code } }
      end

      assert_match 'Payment failed', err.message 
    end
  end

  test "should not create order if payment already exists" do
    @order2 = orders(:two)

    mock = Minitest::Mock.new
    def mock.status
      'succeeded'
    end

    Stripe::PaymentIntent.stub :retrieve, mock do
      err = assert_raises(ActiveRecord::RecordNotUnique) do
        post orders_url, params: { order: { amount_cents: @order.amount_cents, country: @order.country, email_address: @order.email_address, first_name: @order.first_name, last_name: @order.last_name, number: @order.number, postal_code: @order.postal_code, payment_intent: @order2.payment_intent } }
      end
    end
  end

  test "should show order" do
    get order_url(@order), headers: { 'HTTP_AUTHORIZATION' => authorization }
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order), headers: { 'HTTP_AUTHORIZATION' => authorization }
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), 
          params: { order: { amount_cents: @order.amount_cents, country: @order.country, email_address: @order.email_address, first_name: @order.first_name, last_name: @order.last_name, number: @order.number, permalink: @order.permalink } },
          headers: { 'HTTP_AUTHORIZATION' => authorization }
    assert_redirected_to order_url(@order)
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete order_url(@order), headers: { 'HTTP_AUTHORIZATION' => authorization }
    end

    assert_redirected_to orders_url
  end

  private
    def authorization
      ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'password')
    end
end
