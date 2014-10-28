module Download
  
  # Metaclass to make all methods class methods
  class << self 

    def run(url, temp_zip_file)

      # Get head from url
      doc = grab_head(url)

      # Grab the stylesheets urls
      stylesheets = grab_stylesheets_from_head(doc)
      raise ArgumentError, "There are no stylesheets." if stylesheets.nil?

      # Create array of font_files
      input_filenames = build_array_of_font_files(stylesheets, url)

      # Create an array of uri pairs [{ resource: "x", filename: "y" }]
      uris = read_uris_from_file(input_filenames)

      # Download files to temp_zip_file
      download_resources(uris, temp_zip_file)

    end

    def grab_head(url)
      Nokogiri::HTML(open(url)).xpath("/html/head")
    end

    def grab_stylesheets_from_head(doc)
      doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }
    end

    # Parse each stylesheet and rip out the font file urls (eot|woff|ttf|svg)
    def build_array_of_font_files(stylesheets, url)
      stylesheets.map do |stylesheet| 

        css = return_css(url, stylesheet)
        
        # Grab all @font-face declarations
        font_faces = css.scan(/@font-face[^}]*\}/)
        raise ArgumentError, "There are no fonts." if font_faces.nil?

        # Input filenames
        font_urls = grab_font_urls(url, font_faces).flatten
        raise ArgumentError, "There are no fonts." if font_faces.nil?

        # Collect unique font urls
        font_urls.uniq.map { |file| UrlResolver.resolve(url, file) }       

      end.flatten
    end

    def return_css(url, stylesheet)
      # Resolve long url for stylesheet, //, http:// or relative
      link = UrlResolver.resolve(url, stylesheet)

      begin

        # Open stylesheet using Nokogiri & beautify/split css for regex
        css = beautify_css(Nokogiri::HTML(open(link)).to_s)

      rescue OpenURI::HTTPError => e
        if e.message == '404 Not Found'
          # handle 404 error
        else
          raise e
        end
      end
    end

    def beautify_css(string)
      string.split(';').join('; ')
    end

    # Array of font_faces
    def grab_font_urls(url, font_faces)

      # Grab URLS out of @font-face
      font_faces.map do |font|

        # Anything between the brackets
        array = font.scan(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)

        # If array is not empty
        array.flatten.map { |f| f if f[/.eot|.woff|.ttf|.svg/] }.compact if array.any?
      end
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

    def download_resources(pairs, temp_zip_file)
      pairs.each do |pair|
        filename = pair[:filename].to_s
        resource = pair[:resource].to_s
        unless File.exists?(filename)
          download_resource(resource, filename, temp_zip_file)
        else
puts "Skipping download for " + filename + ". It already exists."
        end
      end
    end

    def download_resource(resource, filename, temp_zip_file)
      uri = URI.parse(resource)
      case uri.scheme.downcase
      when /http|https/
        # http_download_uri(uri, filename)
        http_download_uri_and_write_file_to_temp(uri, filename, temp_zip_file)
      # when /ftp/
      #   ftp_download_uri(uri, filename)
      else
puts "Unsupported URI scheme for resource " + resource + "."
      end
    end

    def http_download_uri_and_write_file_to_temp(uri, filename, temp_zip_file)
puts "Starting HTTP download for: " + uri.to_s

      # Net::HTTP is an HTTP client API for Ruby
      # If I am only performing a few GET requests should I try OpenURI?
      http_object = Net::HTTP.new(uri.host, uri.port)
      http_object.use_ssl = true if uri.scheme == 'https'

      begin

        # Open a connection to the server
        http_object.start do |http|

          # Make new Get request
          request = Net::HTTP::Get.new uri.request_uri
puts request.class
          http.read_timeout = 500

          # Create a Net::HTTPResponse object from that request
          http.request request do |response|
puts response

            # Opens the file
            # open filename, 'w' do |io|
              # response.read_body do |chunk|
              #   temp_zip_file.put_next_entry(filename)
            #     # temp_zip_file.print IO.read(chunk)
              #   temp_zip_file.write IO.read(response.body)
              # end
            # end
          end
        end
        
      rescue Exception => e
        puts "=> Exception: '#{e}'. Skipping download."
        return
      end
      puts "Stored download as " + filename + "."
    end




















    # def http_download_uri(uri, filename)
    #   puts "Starting HTTP download for: " + uri.to_s
    #   http_object = Net::HTTP.new(uri.host, uri.port)
    #   http_object.use_ssl = true if uri.scheme == 'https'
    #   begin
    #     http_object.start do |http|
    #       request = Net::HTTP::Get.new uri.request_uri
    #       http.read_timeout = 500
    #       http.request request do |response|
    #         open filename, 'w' do |io|
    #           response.read_body do |chunk|
    #             io.write chunk
    #           end
    #         end
    #       end
    #     end
    #   rescue Exception => e
    #     puts "=> Exception: '#{e}'. Skipping download."
    #     return
    #   end
    #   puts "Stored download as " + filename + "."
    # end

    # def ftp_download_uri(uri, filename)
    #   puts "Starting FTP download for: " + uri.to_s + "."
    #   dirname = File.dirname(uri.path)
    #   basename = File.basename(uri.path)
    #   begin
    #     Net::FTP.open(uri.host) do |ftp|
    #       ftp.login
    #       ftp.chdir(dirname)
    #       ftp.getbinaryfile(basename)
    #     end
    #   rescue Exception => e
    #     puts "=> Exception: '#{e}'. Skipping download."
    #     return
    #   end
    #   puts "Stored download as " + filename + "."
    # end

  end
end