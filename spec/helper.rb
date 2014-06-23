require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'currentuser/data'

require 'request_store'
require 'dotenv'
Dotenv.load

# Check that test application (if any) is really a test one
if ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
  Currentuser::Data::Application.application_id = ENV['CURRENTUSER_APPLICATION_ID_FOR_TESTS']
  unless Currentuser::Data::Application.current.test?
    raise 'CURRENTUSER_APPLICATION_ID_FOR_TESTS should correspond to a test application'
  end
  Currentuser::Data::Application.application_id = nil
end
