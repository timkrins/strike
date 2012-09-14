# encoding: utf-8

require 'optparse'
require 'mysql2'
# require 'sqlite3'
require 'sequel'

module Shield
  class Dump
    def initialize(arguments)
      @options = parse(arguments)
      @hooks = Hash.new { |h, k| h[k] = proc { |row| row } }
      Sequel.extension(:schema_dumper, :migration)
    end

    def parse(arguments = [])
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} dump [OPTIONS] <origin_database_url> [playground_database_url]"

        # TODO: options!
        # opts.on('--hooks a,b,c', Array, 'List of hooks to use')

        options[:origin_db_url]     = arguments.shift.gsub(/^mysql:\/\//, 'mysql2://')
        options[:playground_db_url] = arguments.shift || 'mysql2://root@localhost/shield'
      end

      parser.parse!(arguments)
      options
    end
    protected :parse

    def run
      dump_schema
      dump_data
      # dump_indexes
      # reset_sequences
      # clean_up
    end
    alias call run

    def dump_schema
      $stdout.puts "Dump schema"
      schema = origin_db.dump_schema_migration(:indexes => false)
      migration = eval(schema)
      begin
        migration.apply(playground_db, :down)
      rescue
        $stdout.puts "Small error in migration#down"
      end
      migration.apply(playground_db, :up)
      $stdout.puts playground_db.tables.inspect
    end

    def dump_data
      $stdout.puts "Dump data"
      threads = []
      origin_db.tables.each do |table|
        threads << Thread.new { dump_data_table(table) }
      end
      loop { break unless threads.any?(&:alive?) }
    end

    def dump_data_table(table, limit = 1000)
      origin_table = origin_db[table]
      playground_table = playground_db[table]
      offset = 0
      loop do
        # $stdout.write '.'
        data = origin_table.limit(limit, offset)
        offset += limit
        break if data.count == 0
        playground_table.import(data.all) # TODO: add block to encrypt data
      end
      $stdout.puts <<-OUT
      Origin #{table}: #{origin_table.count}
      Playground #{table}: #{playground_table.count}
      OUT
    end

    def dump_indexes
      $stdout.puts "TODO: Dump indexes"
    end

    def reset_sequences
      $stdout.puts "TODO: Dump sequences"
    end

    def clean_up
      $stdout.puts "TODO: Clean up"
    end

    def origin_db
      @origin_db ||= Sequel.connect(@options[:origin_db_url], :max_connections => 5)
    end

    def playground_db
      @playground_db ||= Sequel.connect(@options[:playground_db_url])
    end
  end
end
