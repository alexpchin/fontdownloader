# Set up gems listed in the Gemfile.
# See: http://gembundler.com/bundler_setup.html
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])

require 'sinatra/base'
require 'uri' 
require 'date' 
require 'net/http' 
require 'net/ftp' 
require 'open-uri' 
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'sprockets'
require 'securerandom'
require 'zip'
require 'sidekiq/web'
require 'nokogiri'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s

# Set up the controllers and helpers
Dir[APP_ROOT.join('app', '*.rb')].each { |file| require file }

# Setup Sidekiq
Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

# Set up the database and models
# require APP_ROOT.join('config', 'database')

# config = YAML.load_file(APP_ROOT.join('config', 'config.yml'))
# config.each do |key, value|
#   ENV[key] = value
# end