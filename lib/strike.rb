# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'tempfile'
require 'thor'

class Strike < Thor
  require 'strike/interpreter'
  require 'strike/agent'

  desc 'version', 'Show version'
  def version
    $stdout.puts "v#{IO.read(File.expand_path('../../VERSION', __FILE__))}"
  end

  desc 'dump <database_url>', 'Dump the <database_url> to STDOUT.'
  long_desc <<-DESC
    Dump the <database_url> following the table definitions defined in the <profile>
    (defaults to `.strike.conf`). The default dump output is STDOUT.

    The <database_url> must have one of the following formats:

    \x5\tmysql://user:password@host/database
    \x5\tmysql://user@host/database

    Usage example:

    $ strike dump mysql://root@localhost/db_production > development_dump.sql

    $ strike dump mysql://root:secret@localhost/db_production --profile=tables.rb > qa_dump.sql

    The tables are defined with a DSL, which is a wrapper
    arround the obfuscation types defined in the MyObfuscate gem.

    Example:
    \x5\t# tables.rb
    \x5\ttable :users do |t|
    \x5\t  # t.column_name :obfuscation_type
    \x5\t  t.name        :first_name
    \x5\t  t.email       :email
    \x5\tend
  DESC
  method_option :profile,
                aliases:   '-p',
                type:      :string,
                default:   'Strikefile',
                required:  true,
                desc:      'Profile with the definitions'
  def dump(database_url)
    file = options[:profile]

    if File.exists?(file)
      File.open(file) do |profile|
        tables = Interpreter.new.parse(profile.read)
        Agent.new(database_url, tables).call
      end
    else
      $stdout.puts "No such file #{file}"
    end
  end
end
