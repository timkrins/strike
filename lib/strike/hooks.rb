# encoding: utf-8

class Strike
  module Hooks
    %w(users credit_cards billing_addresses).each do |hook|
      require "strike/hooks/#{hook}"
    end
  end
end
