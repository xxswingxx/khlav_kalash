# https://guides.rubyonrails.org/active_record_validations.html#custom-validators
# https://github.com/discourse/discourse/blob/master/lib/validators/email_validator.rb

class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end