# encoding: utf-8

class Strike
  class Table
    def initialize(&block)
      @definition ||= {}
      yield self if block_given?
    end

    def method_missing(method, *args, &block)
      @definition[method] = block_given? ?  yield(self) : args.first

      true
    end

    def call
      to_hash
    end

    def to_hash
      @definition
    end
  end
end
