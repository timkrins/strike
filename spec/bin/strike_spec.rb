# encoding: utf-8

require_relative '../minitest_helper'
require 'strike'

describe Strike, 'Use of Strike in the cli' do
  describe '#obfuscate' do
    let(:assets_path) { File.join(File.dirname(__FILE__), '..', 'assets') }
    let(:input)   { "#{assets_path}/dump.sql" }
    let(:profile) { "#{assets_path}/dump_profile.rb" }
    let(:params)  { %W(obfuscate --input=#{input} --profile=#{profile}) }

    it 'should obfuscate the sql dump' do
      out = capture_io { Strike.start(params) }.join('')

      # make sure original names are not retained
      out.wont_match(/Original name/)

      # dump_profile.rb sets this string in each name
      out.must_match(/Obfuscated name/)

      # make sure device data is retained
      out.must_match(/INSERT INTO `devices`/)

      # make sure that the truncate flag works
      out.wont_match(/INSERT INTO `audits`/)
    end
  end
end
