require 'rubygems'
require 'bundler'
require './app'
require './lib/assets'

Bundler.require(:default)

use Assets
run App
