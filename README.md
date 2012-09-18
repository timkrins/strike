# Strike

Command line script to generate mysql dump with encrypted data.
This is a wrapper arround the [my_obfuscate][my_obfuscate] gem.

## Installation

To install it:

    $ gem install strike

## Usage

To see all the options execute:

    $ strike help

To generate a new dump, use the following command:

    $ strike dump mysql://root@localhost/db_production --profile=tables.rb > obfuscate_dump.sql

This command dumps the `database_url` following the tables defined in the `profile`
file (defaults to `Strikefile`). The default dump output is STDOUT.

The `database_url` must have one of the following formats:

    mysql://user:password@host/database
    mysql://user@host/database

It uses the same database url format than [Sequel][sequel].

# Profile file

The profile file is a ruby file with the definitions of the tables that hold
the data that needs to be obfuscated or encrypted. The definitions has
the same format that is specified by the [my_obfuscate][my_obfuscate] gem,
but with a convenient DSL. Not all the data of all the tables needs
to be defined.

By default, the command will search for a `Strikefile` in the current directory.

Example profile file:

```ruby
# tables_definition.rb

table :users do |t|
  # t.column_name :obfuscation_type
  t.name          :first_name
  t.email         :email
end

def some_method
  'Fixed title'
end

table :movies do |t|
  t.title type: fixed, string: some_method
  t.date  type: fixed, string: proc { |row| DateTime.now }
end
```

# Dependencies

* [my_obfuscate][my_obfuscate]: the core of this utility.
* [Sequel][sequel]: extracts the info for the non defined tables.
* [Thor][thor]: cli utilities.

# Notes

* It is only 1.9 compliant.
* Only supports `mysql`.

[my_obfuscate]: https://github.com/jbraeuer/my_obfuscate/
[sequel]: http://sequel.rubyforge.org/
[thor]: https://github.com/wycats/thor
