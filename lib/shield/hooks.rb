# encoding: utf-8

class Shield
  module Hooks
    %w(users credit_cards billing_addresses).each do |hook|
      require "shield/hooks/#{hook}"
    end
  end
end
