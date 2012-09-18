# encoding: utf-8

require 'mysql2'
require 'sequel'
require 'my_obfuscate'

class Strike
  require 'strike/hooks'

  class Dump
    def initialize(type, database_url)
      @db    = connect_to_db(database_url)
      @hooks = hooks_for(type)
    end

    def connect_to_db(database_url)
      Sequel.connect(database_url.gsub(/^mysql:/, 'mysql2:'))
    end
    protected :connect_to_db

    def hooks_for(type)
      hooks = Hash.new { |h, k| h[k] = lambda { :keep } }
      dump_types[type.to_sym].reduce(hooks) do |acc, table|
        hook = Strike::Hooks::const_get(Thor::Util.camel_case(table.to_s))
        acc[table] = hook.new(type)
        acc
      end
    end
    protected :hooks_for

    def dump_types
      {
        development: [:users, :credit_cards, :billing_addresses]
      }
    end
    protected :dump_types

    def run
      tempfile do |tmp|
        dump_data(@db.opts, tmp)
        obfuscate_data(tmp)
      end
    end
    alias call run

    def tempfile(&block)
      tmp = Tempfile.open(['original_dump', 'sql']) do |tmp|
        block.call(tmp)
        tmp
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
        acc[table] = @hooks[table].call
        acc
      end
    end
  end
end
