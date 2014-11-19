module FontDownloader

  class Font
    attr_reader :url, :filename, :extension, :basename

    def initialize(url)
      @url        = get_url(url)
      @fontname   = get_fontname
      @filename   = get_filename
      @extension  = get_extension 
      @basename   = get_basename
      @datastring = download
    end

    def get_url(url)
      url = url.strip
      if url.nil? || url.empty?
        raise ArgumentError, "Incorrectly formatted url given." 
      else
        url
      end
    end

    # Includes things after the extension name ?#iefix
    def get_fontname
      File.basename(url)
    end

    def get_filename
      File.basename(url)[/(?:(?!\?|#).)*/]
    end

    def get_extension
      File.extname(url)
    end

    def get_basename
      File.basename(url)
    end

    # Used to use File.exists? but as only returning string now not checking dir.
    def download
      uri = URI.parse(url)

      case uri.scheme.downcase
      when /http|https/
        http_download_uri(uri)
      # when /ftp/
      #   ftp_download_uri(uri)
      else
        raise ArgumentError, "Unsupported URI scheme for resource #{filename}"
      end
    end

    def http_download_uri(uri)
      puts "Starting HTTP download for: " + uri.to_s
      http_object = Net::HTTP.new(uri.host, uri.port)
      http_object.use_ssl = true if uri.scheme == 'https'
      
      begin
        http_object.start do |http|
          request = Net::HTTP::Get.new uri.request_uri
          http.read_timeout = 500
          http.request request do |response|
            response.read_body
          end
        end
      rescue Exception => e
        # puts "=> Exception: '#{e}'. Skipping download."
        raise e
      end
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