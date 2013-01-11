# encoding: utf-8

require 'my_obfuscate'

class Strike
  class Obfuscator
    def initialize(config = {})
      @adapter_source = config[:adapter_source]
    end

    # Obfuscates the data from input to output with the given information.
    #
    # @param [Hash] tables the tables definitions
    # @param [IO] input the input source to read from.
    # @param [IO] output the output source to write to.
    #
    # @return [nil]
    def call(tables, input, output)
      adapter = adapter_source.call(tables)
      adapter.globally_kept_columns = %w(id created_at updated_at)

      adapter.obfuscate(input, output)
    end

    # Adapter generator.
    def adapter_source
      @adapter_source ||= MyObfuscate.public_method(:new)
    end
    protected :adapter_source
  end
end
