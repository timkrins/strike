# encoding: utf-8

require 'mysql2'
require 'sequel'
require 'my_obfuscate'

class Strike
  class Agent
    def initialize(cli, database_url, tables)
      @cli    = cli
      @db     = connect_to_db(database_url)
      @tables = tables
    end

    def connect_to_db(database_url)
      Sequel.connect(database_url.gsub(/^mysql:/, 'mysql2:'))
    end
    protected :connect_to_db

    def call(output = $stdout)
      tempfile do |file|
        dump_data(@db.opts, file)
        obfuscate_data(file, output)
      end
    end

    def tempfile(&block)
      tmp = Tempfile.open(['original_dump', 'sql']) do |file|
        block.call(file)
        file
      end
    ensure
      tmp.unlink if tmp
    end
    protected :tempfile

    # TODO: support more databases
    def dump_data(db, file)
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

      run dump_cmd(dump_options, file)
    end

    def dump_cmd(options, file)
      "mysqldump #{options} > #{file.path}"
    end
    protected :dump_cmd

    def run(cmd)
      @cli.run cmd, verbose: false, capture: true
    end
    protected :run

    def obfuscate_data(input, output)
      obfuscator = MyObfuscate.new(table_definitions)
      obfuscator.globally_kept_columns = %w(id created_at updated_at)

      obfuscator.obfuscate(input, output)
    end

    def table_definitions
      @db.tables.reduce({}) do |acc, table|
        acc[table] = @tables[table].call
        acc
      end
    end
    protected :table_definitions
  end
end
