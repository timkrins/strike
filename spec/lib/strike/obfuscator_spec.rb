# encoding: utf-8

require_relative '../../minitest_helper'
require 'strike/obfuscator'

describe Strike::Obfuscator do
  let(:input)  { Object.new }
  let(:output) { Object.new }
  let(:tables) { { users: :keep, movies: :keep } }
  let(:adapter_mock) do
    MiniTest::Mock.new.
      expect(:globally_kept_columns=, true, [%w(id created_at updated_at)]).
      expect(:obfuscate, true, [input, output])
  end
  let(:adapter_source) do
    MiniTest::Mock.new.expect(:call, adapter_mock, [tables])
  end
  let(:obfuscator) { Strike::Obfuscator.new(adapter_source) }

  subject { obfuscator }

  describe '#call' do
    it 'should prepare the adapter and call it' do
      subject.call(tables, input, output).must_equal true
    end

    after do
      adapter_source.verify
      adapter_mock.verify
    end
  end
end
