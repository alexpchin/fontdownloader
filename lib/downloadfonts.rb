require 'securerandom'
require 'zip'
require 'open-uri'

module Download
  # Metaclass to make all methods class methods
  class << self 

    # [/^http/], [/^\/\//]
    def get_long_url(url, short_url)
      if !short_url.include?("http")     
        if short_url.include?("//")
          "http:#{short_url}"
        else 
          "#{url}#{short_url}"
        end
      else
        "#{short_url}"
      end
    end

    def create_directory(dirname)
      path = File.expand_path("../../public/uploads/#{dirname}", __FILE__)
      unless File.exists?(path)
        Dir.mkdir(path)
      else
        puts "Skipping creating directory #{path}. It already exists."
      end
      path
    end

    def get_filename(url)
      uri = URI.parse(url)
      File.basename(uri.path) if !uri.path.nil?
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

    # Array of font_faces
    def grab_font_urls(url, font_faces)

      # Grab URLS out of @font-face
      font_faces.map do |font|

        # Anything between the brackets
        array = font.scan(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)

        # If array is not empty
        if array.any?
          array.flatten.map { |f| f if f[/.eot|.woff|.ttf|.svg/] }.compact
        end
      end
    end

    def run(url)

      # Open the desination url using Nokogiri
      page = Nokogiri::HTML(open(url))

      # Select only the head for speed.
      doc = page.xpath("/html/head")

      # Grab the stylsheets urls on the page
      stylesheets = doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }

      # Just for use in the terminal
      puts "FontDownloader has found #{stylesheets.count} stylesheets."

      # Create an array to shovel in font urls
      input_filenames = []

      if stylesheets

        # Parse each stylsheet and rip out the font file urls (eot|woff|ttf|svg)
        stylesheets.each do |s| 

          begin
            # Build long url for stylesheet
            link = get_long_url(url, s)
            
            # Show stylesheet link in terminal
            puts "Stylesheet #{link}"

            # Open stylsheet using Nokogiri
            css = Nokogiri::HTML(open(link)).to_s

            # Beautify css
            css = css.split(';').join('; ')

            # Grab all @font-face declarations
            font_faces = css.scan(/@font-face[^}]*\}/)

            if font_faces
              
              # Input filenames
              font_urls = grab_font_urls(url, font_faces).flatten
            
              input_filenames << font_urls.map { |file|  get_long_url(url, file) }

            else
              return false
            end

          rescue OpenURI::HTTPError => e
            if e.message == '404 Not Found'
              # handle 404 error
            else
              raise e
            end
          end
        end

        input_filenames.flatten!

        # Ensure that the filenames are all uniq
        input_filenames.uniq! if input_filenames

        # Create an array of uri pairs [{ resource: "x", filename: "y" }] for each url
        uris = read_uris_from_file(input_filenames)

        # Create a directory name for this download
        target_dir_name = Date.today.strftime('%y%m%d')

        # Create securehex to add to this download
        hex = SecureRandom.hex

        # Create unique(ish) directory name using target_dir_name and hex
        target_dir_name = "#{target_dir_name}-#{hex}"

        # Create a directory and return absolute path
        path = create_directory(target_dir_name)

        # Changes the current working directory of the process to the given string.
        Dir.chdir(path)
        
        # TO DO - remove
        puts "Changed directory: " + Dir.pwd

        # Download all the URLSs
        download_resources(uris)

        # Build array of filenames on server
        # TO DO = uniq! Should happen further up this process
        input_filenames = uris.map { |file| file[:filename] }.uniq!

        # Zip the directory (folder, input_filenames, zipfile_name)
        zip_file(Dir.pwd, input_filenames, "#{target_dir_name}.zip")

        # Return zip name to controller
        "#{target_dir_name}"

      else
        return false
      end
    end
  end   
end