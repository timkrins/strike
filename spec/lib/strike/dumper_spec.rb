# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/dumper'

describe Strike::Dumper do
  let(:database_url) { 'mysql://test:pass@localhost:3005/test' }
  let(:database_config) do
    {
      db_type:  'mysql',
      host:     'localhost',
      port:     '3005',
      user:     'test',
      password: 'pass',
      database: 'test',
    }
  end

  let(:options) do
    dump_options = %w(-c
                      --add-drop-table
                      --add-locks
                      --single-transaction
                      --set-charset
                      --create-options
                      --disable-keys
                      --quick).join(' ')
    dump_options << " -u #{database_config[:user]}"
    dump_options << " -h #{database_config[:host]}"
    dump_options << " -P #{database_config[:port]}"
    dump_options << " -p#{database_config[:password]}"
    dump_options << " #{database_config[:database]}"

    dump_options
  end

  let(:cli) do
    MiniTest::Mock.new.expect(
      :run,
      true,
      ["mysqldump #{options} > path", { verbose: false, capture: true }]
    )
  end

  let(:dumper) { Strike::Dumper.new }

  subject { dumper }

  describe '#parse_url' do
    it 'should parse the given connection as a url' do
      subject.parse_url(database_url).must_equal database_config
    end
  end

  describe '#dump_data' do
    let(:output) { MiniTest::Mock.new.expect(:path, 'path') }

    it 'should dump data with the default options' do
      subject.dump_data(cli, database_config, output).must_equal true
    end

    after do
      output.verify
      cli.verify
    end
  end

  describe '#call' do
    let(:output) do
      MiniTest::Mock.new.
        expect(:path, 'path').
        expect(:unlink, true).
        expect(:must_equal, true, [MiniTest::Mock])
    end

    let(:dumpfile_source) do
      MiniTest::Mock.new.expect(:call, output, [['original_dump', 'sql']])
    end

    let(:dumper) { Strike::Dumper.new(dumpfile_source: dumpfile_source) }

    it 'should generate dump file with default options and a database_url' do
      subject.call(cli, database_url) do |file|
        file.must_equal output
      end
    end

    after do
      dumpfile_source.verify
      output.verify
      cli.verify
    end
  end
end
