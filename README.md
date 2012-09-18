# Strike

Command line script to generate mysql dump with encrypted data.

## Installation

Install it yourself as:

    $ bundle install
    $ bundle exec rake install

## Usage

To see all the options execute:

    $ strike help

To generate a new dump, use the following command:

    $ strike dump mysql://root@localhost/db_production --type=development > development_dump.sql

This command dumps the `database_url` following the steps defined in the `type`
option (defaults to `development`). The default dump output is STDOUT.

The `database_url` must have one of the following formats:

    mysql://user:password@host/database
    mysql://user@host/database
