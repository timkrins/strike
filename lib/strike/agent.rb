# encoding: utf-8

require 'mysql2'
require 'sequel'
require 'my_obfuscate'

class Strike
  class Agent
    def initialize(database_url, tables)
      @db     = connect_to_db(database_url)
      @tables = tables
    end

    def connect_to_db(database_url)
      Sequel.connect(database_url.gsub(/^mysql:/, 'mysql2:'))
    end
    protected :connect_to_db

    def call
      tempfile do |tmp|
        dump_data(@db.opts, tmp)
        obfuscate_data(tmp)
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

      dump_cmd(dump_options, file)
    end

    def dump_cmd(options, file)
      `mysqldump #{options} > #{file.path}`
    end

    def obfuscate_data(tmp)
      obfuscator = MyObfuscate.new(table_definitions)
      obfuscator.globally_kept_columns = %w(id created_at updated_at)
      obfuscator.obfuscate(tmp, $stdout)
    end

    def table_definitions
      @db.tables.reduce({}) do |acc, table|
        acc[table] = @tables[table].call
        acc
      end
    end
  end
end
