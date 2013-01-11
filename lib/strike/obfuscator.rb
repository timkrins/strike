# encoding: utf-8

require 'my_obfuscate'

class Strike
  class Obfuscator
    def initialize(adapter_source = nil)
      @adapter_source = adapter_source
    end

    def call(tables, input, output)
      adapter = adapter_source.call(tables)
      adapter.globally_kept_columns = %w(id created_at updated_at)

      adapter.obfuscate(input, output)
    end

    def adapter_source
      @adapter_source ||= MyObfuscate.public_method(:new)
    end
    protected :adapter_source
  end
end
