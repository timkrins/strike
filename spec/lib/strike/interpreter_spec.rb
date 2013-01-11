# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/interpreter'

describe Strike::Interpreter do

  let(:table_source) do
    ->(&block) { block ? block.call(table_mock) : Object.new }
  end

  let(:table_mock) do
    MiniTest::Mock.new.expect(:name, true, [:first_name])
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
      tables[:users].wont_be_nil
      table_mock.verify
    end

    it 'should parse tables without a block' do
      tables[:movies].wont_be_nil
    end
  end

  describe '#tables' do
    it 'should have default tables' do
      tables = subject.tables

      tables[:test].call.must_equal :keep
      tables[:test2].call.must_equal :keep
    end
  end
end
