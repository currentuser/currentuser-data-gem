require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'currentuser/data'

require 'request_store'
require 'dotenv'
Dotenv.load
