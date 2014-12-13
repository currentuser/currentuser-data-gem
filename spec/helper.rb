require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require 'request_store'
require 'dotenv'
Dotenv.load

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'currentuser/data'

Currentuser::Data::BaseResource.site = ENV['CURRENTUSER_DATA_URL']
# Check that test project (if any) is really a test one
if ENV['CURRENTUSER_PROJECT_ID_FOR_TESTS']
  Currentuser::Data::Project.project_id = ENV['CURRENTUSER_PROJECT_ID_FOR_TESTS']
  unless Currentuser::Data::Project.current.test?
    raise 'CURRENTUSER_PROJECT_ID_FOR_TESTS should correspond to a test project'
  end
  Currentuser::Data::Project.project_id = nil
end
