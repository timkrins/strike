# encoding: utf-8

require 'strike/table'

class Strike
  class Interpreter
    attr_reader :tables

    def initialize(table_source = nil)
      @table_source = table_source
    end

    # Parse the given profile and generate the tables defined in it.
    #
    # @param [String] profile the profile with the definitions.
    # @return [Hash] all the tables per interpreted table.
    def parse(profile)
      instance_eval(profile)
      tables || []
    end

    # Define a table and its tables.
    #
    # @param [String, Symbol] name the name of the table.
    # @param [Proc] block the block to declare the definitions for the tables.
    def table(name, &block)
      table = table_source.call(&block)

      @tables ||= {}
      @tables[name.to_sym] = table
    end

    def table_source
      @table_source ||= Strike::Table.public_method(:new)
    end
    protected :table_source
  end
end
