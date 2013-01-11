# encoding: utf-8

require 'tempfile'
require 'mysql2'
require 'sequel'
require 'my_obfuscate'

class Strike
  class Agent
    def initialize(config = {})
      @db_connector      = config[:db_connector]
      @dumpfile_source   = config[:dumpfile_source]
      @obfuscator_source = config[:obfuscator_source]
    end

    def connect_to_db(database_url)
      db_connector.call(database_url.gsub(/^mysql:/, 'mysql2:'))
    end
    protected :connect_to_db

    def db_connector
      @db_connector ||= Sequel.public_method(:connect)
    end
    protected :db_connector

    def call(cli, database_url, tables, output = $stdout)
      @cli    = cli
      @db     = connect_to_db(database_url)
      @tables = tables

      tempfile do |file|
        dump_data(@db.opts, file)
        obfuscate_data(file, output)
      end
    end

    def tempfile(&block)
      tmp = dumpfile_source.call(['original_dump', 'sql']) do |file|
        block.call(file)
        file
      end
    ensure
      tmp.unlink if tmp
    end
    protected :tempfile

    def dumpfile_source
      @dumpfile_source ||= Tempfile.public_method(:open)
    end
    protected :dumpfile_source

    # TODO: support more databases
    def dump_data(db_config, file)
      dump_options = %w(-c
                        --add-drop-table
                        --add-locks
                        --single-transaction
                        --set-charset
                        --create-options
                        --disable-keys
                        --quick).join(' ')
      dump_options << " -u #{db_config[:user]}" if db_config[:user]
      dump_options << " -h #{db_config[:host]}" if db_config[:host]
      dump_options << " -P #{db_config[:port]}" if db_config[:port]
      dump_options << " -p#{db_config[:password]}" if db_config[:password]
      dump_options << " #{db_config[:database]}"

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
      obfuscator = obfuscator_source.call(@tables)
      obfuscator.globally_kept_columns = %w(id created_at updated_at)

      obfuscator.obfuscate(input, output)
    end

    def obfuscator_source
      @obfuscator_source ||= MyObfuscate.public_method(:new)
    end
    protected :obfuscator_source
  end
end
