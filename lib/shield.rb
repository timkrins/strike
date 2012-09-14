# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'shield/cmd'

module Shield
  extend self

  def run(argv = [])
    Cmd.new(argv).run
  end
end
