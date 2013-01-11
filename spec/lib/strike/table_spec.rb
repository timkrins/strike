# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/table'

describe Strike::Table do
  let(:hash) { { name: :test } }
  let(:table) { Strike::Table.new }

  subject { table }

  describe '#method_missing' do
    it 'should respond to missing methods' do
      subject.name(:test).wont_be_nil
      subject.test.wont_be_nil
    end
  end

  describe '#to_hash' do
    before { subject.name(:test) }

    it 'should save method calls as hash' do
      subject.to_hash.must_equal hash
    end
  end

  describe '#initialize' do
    let(:table) do
      Strike::Table.new do |t|
        t.name :test
      end
    end

    it 'should accept a block' do
      subject.to_hash.must_equal hash
    end
  end

  describe '#call' do
    it 'should respond with a Hash' do
      subject.call.must_equal Hash.new
    end
  end
end
