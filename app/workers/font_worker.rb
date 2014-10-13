class FontWorker
  include Sidekiq::Worker

  def perform(input_filenames, target_dir_name)
    
    # Create an array of uri pairs [{ resource: "x", filename: "y" }] for each url
    uris = read_uris_from_file(input_filenames)

    # Create a directory and return absolute path
    path = create_directory(target_dir_name)

    # Changes the current working directory of the process to the given string.
    Dir.chdir(path)

    # Download all the Files from the urls
    download_resources(uris)

    # Build array of filenames on server
    # TO DO = uniq! Should happen further up this process
    input_filenames = uris.map { |file| file[:filename] }.uniq!

    # Zip the directory (folder, input_filenames, zipfile_name)
    zip_file(Dir.pwd, input_filenames, "#{target_dir_name}.zip")

  end

  def read_uris_from_file(files)
    files.map do |url|
      url = url.strip
      next if url == nil || url.length == 0
      pair = { resource: url, filename: get_filename(url) }
    end
  end

  def download_resource(resource, filename)
    uri = URI.parse(resource)
    case uri.scheme.downcase
    when /http|https/
      http_download_uri(uri, filename)
    when /ftp/
      ftp_download_uri(uri, filename)
    else
      puts "Unsupported URI scheme for resource " + resource + "."
    end
  end

  def http_download_uri(uri, filename)
    puts "Starting HTTP download for: " + uri.to_s
    http_object = Net::HTTP.new(uri.host, uri.port)
    http_object.use_ssl = true if uri.scheme == 'https'
    begin
      http_object.start do |http|
        request = Net::HTTP::Get.new uri.request_uri
        http.read_timeout = 500
        http.request request do |response|
          open filename, 'w' do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    rescue Exception => e
      puts "=> Exception: '#{e}'. Skipping download."
      return
    end
    puts "Stored download as " + filename + "."
  end

  def ftp_download_uri(uri, filename)
    puts "Starting FTP download for: " + uri.to_s + "."
    dirname = File.dirname(uri.path)
    basename = File.basename(uri.path)
    begin
      Net::FTP.open(uri.host) do |ftp|
        ftp.login
        ftp.chdir(dirname)
        ftp.getbinaryfile(basename)
      end
    rescue Exception => e
      puts "=> Exception: '#{e}'. Skipping download."
      return
    end
    puts "Stored download as " + filename + "."
  end

  def download_resources(pairs)
    pairs.each do |pair|
      filename = pair[:filename].to_s
      resource = pair[:resource].to_s
      unless File.exists?(filename)
        download_resource(resource, filename)
      else
        puts "Skipping download for " + filename + ". It already exists."
      end
    end
  end

  def zip_file(folder, input_filenames, zipfile_name)

    # Create a new zipped directory
    Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|

      input_filenames.each do |filename|
        # Two arguments: (new_file_name, original_file_path)
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(filename, "#{folder}/#{filename}")
      end

      # If you want to generate a README ?
      # zipfile.get_output_stream("myFile") { |os| os.write "myFile contains just this" }

    end
  end
end