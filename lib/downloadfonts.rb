require 'pry'
require 'securerandom'
require 'zip'

module Download
  # Metaclass to make all methods class methods
  class << self 

    # def get_long_url(url, short_url)
    #   if !short_url[/^http/]
    #     if short_url[/^\/\//]
    #       "http:#{short_url}"
    #     else 
    #       url + short_url
    #     end
    #   else
    #     short_url
    #   end
    # end

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
    def grab_font_urls(font_faces)

      # Grab URLS out of @font-face
      input_filenames = font_faces.map do |font|

        # Grab all urls after http (also catches https)
        font.scan(/http(.*?)\.(?:eot|woff|ttf|svg)/)

        # Grab all urls after // or /
        font.scan(/\/(.*?)\.(?:eot|woff|ttf|svg)/).map |u|
          
          # Only if url doesn't include http or https 
          if !u.include?("http")
            if u.include?(//)
              "http:#{u}"
            else
              "#{url}#{u}"
            end
          end 

        end.flatten!

      end

binding.pry

    end

    def run(url)
      # Open the desination url using Nokogiri
      page = Nokogiri::HTML(open(url))

      # Select only the head.
      doc =  page.xpath("/html/head")

      # Grab the stylsheets on the page
      stylesheets = doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }

      # TO DO - remove
      puts "FontDownloader has found #{stylesheets.count} stylesheets."

      # Create an empty array to save file urls
      input_filenames = []

      # Parse each stylsheet and rip out the font file urls (eot|woff|ttf|svg)
      stylesheets.each do |s| 
        begin
          link = get_long_url(url, s)
          
          puts link
          
          css = Nokogiri::HTML(open(link)).to_s

          # This regex will grab all relevant filenames
          # /\.(ttf|eot|svg|woff)(\?v=[0-9]\.[0-9]\.[0-9])?/
          # \[(.*?)\] Everything beteen the square brackets
          # Old (broken?) /src:url(\(.*?\.(?:eot|woff|ttf|svg))/
          
          # New: \/\/(.*?)\.(?:eot|woff|ttf|svg)
          # Problem, will grab everything after first //

          # Beautify css
          css = css.split(';').join('; ')

          # Grab all @font-face declarations
          font_faces = css.scan(/@font-face[^}]*\}/)

          input_filenames = grab_font_urls(url, font_faces)

          # input_filenames.map do { |filename| 
          #   get_long_url(filename
          # end

          # Grab URLS out of @font-face
          # input_filenames = fontfaces.map do |font| 

          #   font.scan(/\/\/(.*?)\.(?:eot|woff|ttf|svg)/).map do |s|
          #     # TO DO, add into Regex 
          #     v = s[0].delete!('()"')

          #     # Quick fix to solve problem of urls with // instead of http(s)
          #     get_long_url(url, s[0]) if v
          #   end

          # end

        rescue OpenURI::HTTPError => e
          if e.message == '404 Not Found'
            # handle 404 error
          else
            raise e
          end
        end
      end

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
    end

  end   
end