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


 
# # Create an array of uri pairs [{ resource: "x", filename: "y" }] for each url
# uris = read_uris_from_file(input_filenames)

# # Create a directory and return absolute path
# path = create_directory(target_dir_name)

# # Changes the current working directory of the process to the given string.
# Dir.chdir(path)

# # Download all the Files from the urls
# download_resources(uris)

# # Build array of filenames on server
# input_filenames = uris.map { |file| file[:filename] }

# # Zip the directory (folder, input_filenames, zipfile_name)
# zip = zip_file(Dir.pwd, input_filenames, "#{target_dir_name}.zip")

# uploader = FontUploader.new
# uploader.store! zip