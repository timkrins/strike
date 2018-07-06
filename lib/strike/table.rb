# encoding: utf-8

class Strike
  class Table
    def initialize(flag, &block)
      @definition ||= flag || {}
      yield self if block_given?
    end

    def method_missing(method, *args, &block)
      return super unless @definition.is_a?(Hash)

      @definition[method] = block_given? ? yield(self) : args.first

      true
    end

    def respond_to_missing?(_method, _include_private)
      @definition.is_a?(Hash)
    end

    def call
      to_hash
    end

    def to_hash
      @definition
    end
  end
end
