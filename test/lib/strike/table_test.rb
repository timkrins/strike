# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/table'

class Strike::TableTest < MiniTest::Unit::TestCase
  def setup
    @table = Strike::Table.new
  end

  def test_should_respond_to_missing_methods
    assert @table.name(:test)
    assert @table.test
  end

  def test_should_map_methods_as_keys
    expected = { name: :test }
    @table.name(:test)

    assert_equal expected, @table.to_hash
  end

  def test_should_respond_to_call
    assert_equal Hash.new, @table.call
  end

  def test_should_accept_a_block_when_its_initialized
    table = Strike::Table.new do |t|
      t.name :test
    end
    expected = { name: :test }

    assert_equal expected, table.to_hash
  end
end
