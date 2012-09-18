# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/interpreter'

class Strike::InterpreterTest < MiniTest::Unit::TestCase
  def setup
    @interpreter = Strike::Interpreter.new(table_source)
    @profile = <<-PROFILE
    table :users do |t|
      t.name :first_name
    end

    table :movies
    PROFILE
  end

  def test_should_parse_a_profile_into_tables
    tables = @interpreter.parse(@profile)

    assert_equal 2, tables.count
    assert tables[:users]
    assert tables[:movies]

    table_mock.verify
  end

  def test_should_have_default_tables
    tables = @interpreter.tables

    assert_equal :keep, tables[:test].call
    assert_equal :keep, tables[:test2].call
  end

  private

  def table_source
    ->(&block) { block ? block.call(table_mock) : table_mock }
  end

  def table_mock
    @table_mock ||= MiniTest::Mock.new.expect(:name, true, [:first_name])
  end
end
