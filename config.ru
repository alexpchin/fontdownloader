#!/usr/bin/env rackup
# encoding: utf-8

require File.expand_path("../config/environment.rb", __FILE__)

# Using Rack URLMap for multiple Sinatra apps
run Rack::URLMap.new({
  "/"         => FontDownloader::App
})
