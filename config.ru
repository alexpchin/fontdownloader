#!/usr/bin/env rackup
# encoding: utf-8

require File.expand_path("../config/boot.rb", __FILE__)

# Using Rack URLMap for multiple Sinatra apps
run Rack::URLMap.new({
  "/"         => FontDownloader::App,
  "/sidekiq"  => Sidekiq::Web,
  "/assets"   => FontDownloader::Assets
})
