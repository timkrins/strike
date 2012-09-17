# encoding: utf-8

class Shield
  module Hooks
    class Users < Struct.new(:dump_type)
      def call
        {
          email:                { type: :email, skip_regexes: email_regexes },
          username:             :first_name,
          cached_slug:          :first_name,
          mailchimp_merge_vars: { type: :fixed, string: mailchimp_merge_vars },
        }
      end

      protected

      def email_regexes
        # TODO: add more emails?
        [/^[\w\.\_]+@wuaki\.tv$/i]
      end

      def mailchimp_merge_vars
        '---\nFNAME: nobody\nCREDITCARD: \'No\'\nACTIVE: \'No\'\nGENDER: \nBIRTHDAY: 5/2\nAGE: 42\nTVUSER: \'No\'\nSUBSCRIBED: \'No\'\nLANGUAGE: Spanish\nPARENTAL: X\n'
      end
    end
  end
end
