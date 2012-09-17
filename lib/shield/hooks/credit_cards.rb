# encoding: utf-8

class Shield
  module Hooks
    class CreditCards < Struct.new(:dump_type)
      def call
        {
          month:            { type: :fixed, string: '01' },
          year:             { type: :fixed, string: '23' },
          encrypted_number: { type: :fixed, string: proc { test_credit_card } },
          holder_name:      :name,
        }
      end

      protected

      def test_credit_card
        ["QsqAaFsVkvcdH35PLqgsLlNlGsNMoyO6RMCK/ir2b4A=\n",
         "gvTu2P8IAPzig8JGN2kL/ZrCVnvX4o8JNFIFwiXQWwM=\n",
         "1vov7jI4RZTH86P6h/MxbeYyH8E2x1NSuEZL/RNebo8=\n",
         "/BG6CLaKksGRaKX0HNkGXgluVLdT2pvsOLwtWFrC8xs=\n"].sample
      end
    end
  end
end
