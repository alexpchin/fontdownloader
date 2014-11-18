module FontDownloader

  class Font
    attr_reader :url, :dirpath, :filename, :filepath, :extension, :basename

    def initialize(url, dirpath)
      @url       = set_url(url)
      @dirpath   = dirpath
      @fontname  = set_fontname
      @filename  = set_filename
      @filepath  = set_filepath
      @extension = set_extension 
      @basename  = set_basename
    end

    # def create_tempfile
    #   Tempfile.new(filename) << download
    # end

    def set_url(url)
      url = url.strip
      if url.blank?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url
      end
    end

    def set_fontname
      File.basename(url)
    end

    def set_filename
      File.basename(url)[/(?:(?!\?|#).)*/]
    end

    def set_filepath
      "#{dirpath}/#{filename}"
    end

    def set_basename
      File.basename(url)
    end

    def set_extension
      File.extname(url)
    end

    def download
      unless File.exists?(filename)
        download_resource
      else
        puts "Skipping download for " + filename + ". It already exists."
      end
    end

    def download_resource
      uri = URI.parse(url)

      case uri.scheme.downcase
      when /http|https/
        http_download_uri(uri)
      # when /ftp/
      #   ftp_download_uri(uri)
      else
        puts "Unsupported URI scheme for resource " + filename
      end
    end

    def http_download_uri(uri)
      puts "Starting HTTP download for: " + uri.to_s
      http_object = Net::HTTP.new(uri.host, uri.port)
      http_object.use_ssl = true if uri.scheme == 'https'
      begin
        http_object.start do |http|
          request = Net::HTTP::Get.new uri.request_uri
puts uri.request_uri
puts request

          http.read_timeout = 500
          http.request request do |response|

            # Writes the file, needs to include extension
            # open filename, 'w' do |io|
            #   response.read_body do |chunk|
            #     io.write chunk
            #   end
            # end

# puts response.read_body
            # Return the file body
            response.read_body


            # response.read_body do |chunk|
            #   io.write chunk
            # end

          end
        end
      rescue Exception => e
        puts "=> Exception: '#{e}'. Skipping download."
        return
      end
      puts "Stored download as " + filename
    end

    # def ftp_download_uri(uri)
    #   puts "Starting FTP download for: " + uri.to_s
    #   begin
    #     Net::FTP.open(uri.host) do |ftp|
    #       ftp.login
    #       ftp.chdir(dirpath)
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