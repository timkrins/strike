# encoding: utf-8

require 'tempfile'
require 'uri'

class Strike
  class Dumper
    def initialize(config = {})
      @dumpfile_source = config[:dumpfile_source]
    end

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

    def tempfile
      tmp = dumpfile_source.call(['original_dump', 'sql'])
      block_given? ? yield(tmp) : tmp
    end
    protected :tempfile

    def dumpfile_source
      @dumpfile_source ||= Tempfile.public_method(:new)
    end
    protected :dumpfile_source

    # TODO: support more databases
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

    def dump_cmd(options, file)
      "mysqldump #{options} > #{file.path}"
    end
    protected :dump_cmd

    def run(cli, cmd)
      cli.run cmd, verbose: false, capture: true
    end
    protected :run
  end
end
