# encoding: utf-8

class Shield
  module Hooks
    class BillingAddresses < Struct.new(:dump_type)
      def call
        {
          address1: :street_address,
          address2: :null,
          city:     :city,
          state:    :state,
          zip:      :zip_code,
          phone:    :phone,
          company:  :company,
        }
      end
    end
  end
end
