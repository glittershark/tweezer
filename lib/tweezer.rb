require 'set'
require 'tweezer/version'
require 'tweezer/errors'
require 'tweezer/gemfile'
require 'tweezer/gem'
require 'tweezer/unparser/emitter/unparenthesized_arguments'
require 'tweezer/unparser/emitter/send/regular'

module Tweezer
  UNPARENTHESIZED_METHODS = Set[*%i(source ruby git path group platforms gem)]

  def self.unparenthesized_method?(method)
    UNPARENTHESIZED_METHODS.include?(method)
  end
end
