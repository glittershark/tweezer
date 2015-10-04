$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tweezer'

require 'rspec/collection_matchers'
require 'rspec/its'
require 'active_support/all'
require 'coveralls'

Coveralls.wear!
