require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  should validate_presence_of(:first_name)
  should validate_presence_of(:country)
  should validate_presence_of(:postal_code)
  should validate_presence_of(:email_address)
end
