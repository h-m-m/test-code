require 'minitest/autorun'
require 'rack/test'

require File.expand_path "../service.rb", __FILE__

include Rack::Test::Methods

def app
  Sinatra::Application
end

