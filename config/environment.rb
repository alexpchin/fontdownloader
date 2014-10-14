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

require 'securerandom'
require 'zip'

require 'nokogiri'
require 'sprockets'
require 'sass'
require 'haml'
require 'carrierwave'
require 'sidekiq/web'
require 'redis'
# require 'autoscaler'
# require 'autoscaler/sidekiq'
# require 'autoscaler/heroku_scaler'

# Some helper constants for path-centric logic
APP_ROOT = Pathname.new(File.expand_path('../../', __FILE__))
APP_NAME = APP_ROOT.basename.to_s

# Set up the app files
Dir[APP_ROOT.join('app', '*.rb')].each { |file| require file }

# # Setup Sidekiq
Sidekiq.configure_client do |config|
  config.redis = { 
    size: 1
  }
end

# Sidekiq.configure_client do |config|
#   config.client_middleware do |chain|
#     chain.add Autoscaler::Sidekiq::Client, 'default' => Autoscaler::HerokuScaler.new
#   end
# end

# Sidekiq.configure_server do |config|
#   config.server_middleware do |chain|
#     chain.add(Autoscaler::Sidekiq::Server, Autoscaler::HerokuScaler.new, 60)
#   end
# end

# Setup carrierwave
CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
  }
  config.fog_directory  = ENV['AWS_BUCKET_FONTDOWNLOADER']
end

# Set up the sidekiq workers
Dir[APP_ROOT.join('app', 'workers', '*.rb')].each { |file| require file }

# Set up the uploaders
Dir[APP_ROOT.join('app', 'uploaders', '*.rb')].each { |file| require file }

# Set up the database and models
# require APP_ROOT.join('config', 'database')

# config = YAML.load_file(APP_ROOT.join('config', 'config.yml'))
# config.each do |key, value|
#   ENV[key] = value
# end