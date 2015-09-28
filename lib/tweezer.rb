require 'set'

module Tweezer
  UNPARENTHESIZED_METHODS = Set[*%i(source ruby git path group platforms gem)]

  def self.unparenthesized_method?(method)
    UNPARENTHESIZED_METHODS.include?(method)
  end
end

require 'unparser'
require 'tweezer/unparser/buffer'
require 'tweezer/unparser/emitter'
require 'tweezer/unparser/emitter/literal/primitive/inspect'
require 'tweezer/unparser/emitter/send/regular'
require 'tweezer/unparser/emitter/unparenthesized_arguments'
require 'tweezer/unparser/emitter/blank_line'
require 'tweezer/version'
require 'tweezer/errors'
require 'tweezer/gem'
require 'tweezer/gemfile'
require 'tweezer/cli'
