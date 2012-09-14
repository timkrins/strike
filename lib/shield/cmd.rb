# encoding: utf-8

require 'shield/version'
require 'shield/dump'

module Shield
  class Cmd
    def initialize(argv)
      @action    = (argv.shift || 'help').to_s
      @arguments = argv.dup
    end

    def run
      send(@action)
    end

    def help
      $stdout.puts <<EOHELP
Options
=======
help      Show this help message
dump      Dump a mysql database with sensitive data encrypted
version   Show version

Add '-h' to any command to see their usage
EOHELP
    end

    def version
      $stdout.puts Shield::VERSION
    end

    def dump
      Dump.new(@arguments).run
    end

    def method_missing(method, *args, &block)
      $stderr.puts "Error: action #{method} not recognized"
      exit false
    end
  end
end
