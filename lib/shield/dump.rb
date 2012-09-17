# encoding: utf-8

require 'tempfile'
require 'optparse'
require 'mysql2'
require 'sequel'
require 'my_obfuscate'

module Shield
  class Dump
    def initialize(arguments)
      @options = parse(arguments)
      @hooks = Hash.new { |h, k| h[k] = proc { |row| row } }
      # Sequel.extension(:schema_dumper, :migration)
    end

    def parse(arguments = [])
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} dump [OPTIONS] <origin_database_url>"

        # TODO: options!
        # opts.on('--hooks a,b,c', Array, 'List of hooks to use')

        options[:origin_db_url] = arguments.shift.gsub(/^mysql:\/\//, 'mysql2://')
      end

      parser.parse!(arguments)
      options
    end

    def run
      tmp = tempfile do |tmp|
        dump_data(origin_db.opts, tmp)
        obfuscate_data(tmp)
      end
    ensure
      tmp.unlink if tmp
    end
    alias call run

    def tempfile(&block)
      Tempfile.open(['original_dump', 'sql']) do |tmp|
        block.call(tmp)
      end
    end

    def dump_data(db, tmp)
      dump_options = %w(-c
                        --add-drop-table
                        --add-locks
                        --single-transaction
                        --set-charset
                        --create-options
                        --disable-keys
                        --quick).join(' ')
      dump_options << " -u #{db[:user]}" if db[:user]
      dump_options << " -h #{db[:host]}" if db[:host]
      dump_options << " -P #{db[:port]}" if db[:port]
      dump_options << " -p#{db[:password]}" if db[:password]
      dump_options << " #{db[:database]}"

      dump_cmd(dump_options, tmp)
    end

    def dump_cmd(options, file)
      `mysqldump #{options} > #{file.path}`
    end

    def obfuscate_data(tmp)
      definitions = table_definitions
      definitions.merge!(:users => {
        :email    => { :type => :email, :skip_regexes => [/^[\w\.\_]+@wuaki\.tv$/i] },
        :username => :first_name
      })

      obfuscator = MyObfuscate.new(definitions)
      # obfuscator.fail_on_unspecified_columns = true # if you want it to require every column in the table to be in the above definition
      obfuscator.globally_kept_columns = %w[id created_at updated_at] # if you set fail_on_unspecified_columns, you may want this as well
      obfuscator.obfuscate(tmp, $stdout)
    end

    def table_definitions
      origin_db.tables.reduce({}) do |acc, table|
        acc[table] = :keep
        acc
      end
    end

    def origin_db
      @origin_db ||= Sequel.connect(@options[:origin_db_url], :max_connections => 5)
    end
  end
end
