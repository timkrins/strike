# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/interpreter'

describe Strike::Interpreter do

  let(:table_users) { { name: :keep } }
  let(:table_movies) { :keep }

  let(:table_source) do
    ->(flag, &block) { block ? block.call(table_mock) : -> { table_movies } }
  end

  let(:table_users) { {name: :keep } }

  let(:table_mock) do
    tb = MiniTest::Mock.new.expect(:call, table_users)

    MiniTest::Mock.new.expect(:name, tb, [:first_name])
  end

  let(:profile) do
    <<-PROFILE
    table :users do |t|
      t.name :first_name
    end

    table :movies
    PROFILE
  end

  subject { Strike::Interpreter.new(table_source) }

  describe '#parse' do
    let(:tables) { subject.parse(profile) }

    it 'should parse all profile tables' do
      tables.count.must_equal 2
    end

    it 'should parse tables with a block' do
      tables[:users].must_equal table_users
      table_mock.verify
    end

    it 'should parse tables without a block' do
      tables[:movies].must_equal table_movies
    end
  end

  describe '#tables' do
    let(:tables) { subject.tables }

    it 'should have default tables' do
      tables[:test].must_equal :keep
      tables[:test2].must_equal :keep
    end
  end
end
