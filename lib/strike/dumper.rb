# encoding: utf-8

require 'tempfile'
require 'uri'

class Strike
  class Dumper
    def initialize(config = {})
      @dumpfile_source = config[:dumpfile_source]
    end

    # Dumps the data from the given database to a tmp file.
    #
    # @param [#run] cli the cli program that responds to `#run`.
    # @param [String] database_url the connection info. @see `#parse_url`.
    # @param [Proc] optional block in which the tmp file will be used.
    #
    # @return [nil]
    def call(cli, database_url)
      tempfile do |file|
        begin
          dump_data(cli, parse_url(database_url), file)
          yield(file) if block_given?
        ensure
          file.unlink
        end
      end
    end

    # Converts a database_url to Hash with all the db data.
    #
    # Example:
    #   parse_url('mysql://user:pass@localhost:100/test_db')
    #
    # @param [String] database_url the connection info.
    #
    # @return [Hash] the database configuration with the following fields.
    #                {
    #                  db_type: String || nil,
    #                  host: String || nil,
    #                  port: String || nil,
    #                  user: String || nil,
    #                  password: String || nil,
    #                  database: String || nil,
    #                }
    def parse_url(database_url)
      uri = URI.parse(database_url)

      {
        db_type:  uri.scheme.gsub(/^mysql2/, 'mysql'),
        host:     uri.host,
        port:     uri.port.to_s,
        user:     uri.user,
        password: uri.password,
        database: uri.path.gsub(/^\//, ''),
      }
    end

    # Create a tmp file
    #
    # @param [Proc] yields the file.
    #
    # @return [nil, Tempfile]
    def tempfile
      tmp = dumpfile_source.call(['original_dump', 'sql'])
      block_given? ? yield(tmp) : tmp
    end
    protected :tempfile

    # Tmp file generator
    #
    # @return [Proc] a lambda that generates the file.
    def dumpfile_source
      @dumpfile_source ||= Tempfile.public_method(:new)
    end
    protected :dumpfile_source

    # Dump the data from the database configuration and
    # outputs it to the given file.
    #
    # @param [#run] cli the cli program that responds to `#run`.
    # @param [Hash] db_config database configuration from `#parse_url`.
    # @param [Tempfile, IO, File] file the file to write the dump.
    #
    # @return [nil]
    def dump_data(cli, db_config, file)
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
      if db_config[:port] && !db_config[:port].empty?
        dump_options << " -P #{db_config[:port]}"
      end
      dump_options << " -p#{db_config[:password]}" if db_config[:password]
      dump_options << " #{db_config[:database]}"

      run cli, dump_cmd(dump_options, file)
    end

    # Dump cli command
    def dump_cmd(options, file)
      "mysqldump #{options} > #{file.path}"
    end
    protected :dump_cmd

    # Run the command with the cli
    #
    # @param [#run] cli the cli program that responds to `#run`.
    # @param [String] cmd the command to run.
    #
    # @return [nil]
    def run(cli, cmd)
      cli.run cmd, verbose: false, capture: true
    end
    protected :run
  end
end
