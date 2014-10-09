require 'rubygems'
require 'bundler'
require './app'
require_relative './lib/assets'

Bundler.require(:default)

use Assets
run App
