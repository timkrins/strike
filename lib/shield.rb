# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'shield/cmd'

module Shield
  extend self

  def run(argv = [])
    Cmd.new(argv).run
    # definitions = table_definitions
    # definitions.merge!(:users => {
      # :email    => { :type => :email, :skip_regexes => [/^[\w\.\_]+@wuaki\.tv$/i] },
      # :username => :name
    # })

    # obfuscator = MyObfuscate.new(definitions)
    # # obfuscator.fail_on_unspecified_columns = true # if you want it to require every column in the table to be in the above definition
    # obfuscator.globally_kept_columns = %w[id created_at updated_at] # if you set fail_on_unspecified_columns, you may want this as well
    # obfuscator.obfuscate($stdin, $stdout)
  end

  # def table_definitions
    # db = Sequel.connect('mysql2://root@localhost/shield')
    # db.tables.reduce({}) do |acc, table|
      # acc[table] = :keep
      # acc
    # end
  # end
end
