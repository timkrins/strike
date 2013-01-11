# encoding: utf-8

require 'thor'

class Strike < Thor
  require 'strike/interpreter'
  require 'strike/obfuscator'
  require 'strike/agent'

  include Thor::Actions

  class_option :profile,
               aliases:   '-p',
               type:      :string,
               default:   'Strikefile',
               required:  false,
               desc:      'Profile with the table definitions.'
  class_option :output,
               aliases:   '-o',
               type:      :string,
               required:  false,
               desc:      'Output file. If none is given, outputs to STDOUT.'

  desc 'version', 'Show version'
  def version
    $stdout.puts "v#{IO.read(File.expand_path('../../VERSION', __FILE__))}"
  end

  desc 'dump <database_url>', 'Dump the <database_url> to STDOUT.'
  long_desc <<-DESC
    Dump the <database_url> following the table definitions defined in the <profile>
    (defaults to `Strikefile`). The default dump output is STDOUT.

    The <database_url> must have one of the following formats:

    \x5\tmysql://user:password@host/database
    \x5\tmysql://user@host/database

    Usage example:

    $ strike dump mysql://root@localhost/db_production > dump.sql

    $ strike dump mysql://root:secret@localhost/db_production --profile=tables.rb > dump.sql

    The tables are defined with a DSL, which is a wrapper
    arround the obfuscation types defined in the MyObfuscate gem.

    Example:
    \x5\t# tables.rb
    \x5\ttable :users do |t|
    \x5\t  # t.column_name :obfuscation_type
    \x5\t  t.name          :first_name
    \x5\t  t.email         :email
    \x5\tend
  DESC
  def dump(database_url)
    file = options[:profile]

    if options[:output]
      modes  = File::CREAT|File::TRUNC|File::RDWR
      output = File.new(options[:output], modes, 0644)
    end

    if file && File.exist?(file)
      File.open(file) do |profile|
        tables = Interpreter.new.parse(profile.read)
        Agent.new.call(self, database_url, tables, output || $stdout)
      end
    else
      $stderr.puts "Profile Error: No such file #{file}"
    end
  ensure
    output.close if output
  end

  desc 'obfuscate', 'Obfuscate a mysqldump from --input to --output.'
  long_desc <<-DESC
    Obfuscate the database dump following the table definitions defined in the <profile>
    (defaults to `Strikefile`). The default obfuscate output is STDOUT and the input
    is STDIN.

    The mysqldump must has been generated with the `-c` option.

    Usage example:

    $ strike obfuscate < dump.sql > obfuscated-dump.sql

    $ cat dump.sql | strike obfuscate > obfuscated-dump.sql --profile=tables.rb

    $ strike obfuscate --input=dump.sql --output=obfuscated-dump.sql

    The tables are defined with a DSL, which is a wrapper
    arround the obfuscation types defined in the MyObfuscate gem.

    Example:
    \x5\t# tables.rb
    \x5\ttable :users do |t|
    \x5\t  # t.column_name :obfuscation_type
    \x5\t  t.name          :first_name
    \x5\t  t.email         :email
    \x5\tend
  DESC
  class_option :input,
               aliases:   '-i',
               type:      :string,
               required:  false,
               desc:      'Input file. If none is given, is read from STDIN.'

  def obfuscate
    with_profile do |profile|
      with_input do |input|
        with_output do |output|
          tables = Interpreter.new.parse(profile.read)
          Obfuscator.new.call(tables, input, output)
        end
      end
    end
  end

  private

  def with_input
    input = options[:input] ? File.open(options[:input]) : $stdin

    yield input
  ensure
    input.close if input != $stdin
  end

  def with_output
    output = if options[:output]
               modes  = File::CREAT|File::TRUNC|File::RDWR
               File.new(options[:output], modes, 0644)
             else
               $stdout
             end

    yield output
  ensure
    output.close if output != $stdout
  end

  def with_profile
    file = options[:profile]

    if file && File.exist?(file)
      File.open(file) do |profile|
        yield profile
      end
    else
      $stderr.puts "Profile Error: No such file #{file}"
    end
  end
end
