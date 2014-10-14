## Other useful Redis commands
# redis-cli shutdown
# redis-server /usr/local/etc/redis.conf
# Sidekiq.redis { |conn| conn.info }
# ps aux | grep sidekiq

## Clear Sidekiq
# Sidekiq.redis {|c| c.del('stat:processed') }
# Sidekiq.redis {|c| c.del('stat:failed') }
# Sidekiq.redis {|c| c.del('stat:enqueued') }

## Test Redis
# bundle exec irb 
# require 'sidekiq'
# require './app/workers/font_worker'
# require 'carrierwave' 
# require './app/uploaders/font_uploader'
# FontWorker.perform_async(['http://ga-core-production-herokuapp-com.global.ssl.fastly.net/assets/PFDin/pfdintextcomppro-medium-webfont-4a5044fb8033b258c88edde52d658dbb.ttf'], '141013-cfe39eb4d6fd9824f38d5fcad5d8cbf6.zip')

## Start Redis
# bundle exec sidekiq -r ./config/environment.rb