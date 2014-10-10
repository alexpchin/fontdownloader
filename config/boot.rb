ENV["RACK_ENV"] ||= "development"

require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require 'sidekiq/web'
Sidekiq.configure_client do |config|
  config.redis = { :size => 1 }
end

Dir["./lib/**/*.rb"].each { |f| require f }