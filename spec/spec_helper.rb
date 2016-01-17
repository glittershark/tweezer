require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tweezer'

require 'rspec/collection_matchers'
require 'rspec/its'

# from ActiveSupport
class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
