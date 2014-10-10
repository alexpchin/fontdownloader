#!/usr/bin/env rackup
# encoding: utf-8

require File.expand_path("../config/boot.rb", __FILE__)

# Using Rack URLMap for multiple Sinatra apps
run Rack::URLMap.new({
  "/"       => FontDownloader::App,
  "/admin"  => FontDownloader::Sidekiq,
  "/assets" => FontDownloader::Assets
})
