# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'tempfile'
require 'thor'

class Shield < Thor
  require 'shield/dump'

  desc 'version', 'Show version'
  def version
    $stdout.puts "v#{IO.read(File.expand_path('../../VERSION', __FILE__))}"
  end

  desc 'dump <database_url>', 'Dump the <database_url> to STDOUT.'
  long_desc <<-DESC
    Dump the <database_url> following the steps defined in the <type>
    (defaults to `development`). The default dump output is STDOUT.

    The <database_url> must have one of the following formats:

      > mysql://user:password@host/database

      > mysql://user@host/database

    Usage example:

      $ shield dump mysql://root@localhost/db_production > development_dump.sql

      $ shield dump mysql://root:secret@localhost/db_production --type=qa > qa_dump.sql
  DESC
  method_option :type,
                aliases:   '-t',
                type:      :string,
                default:   'development',
                required:  true,
                desc:      'Type of dump to generate. Types: `development`'
  def dump(database_url)
    Dump.new(options[:type], database_url).run
  end
end
