module FontDownloader
  
  # class << self
  class Download
    attr_reader :url, :tmp_folder

    def initialize(url, tmp_folder)
      @url        = url
      @tmp_folder = tmp_folder
    end

    def run
      @doc = grab_head
      @stylesheets = grab_stylesheets_from_head
    end

    def grab_head
      Nokogiri::HTML(open(url)).xpath("/html/head")
    end

    def grab_stylesheets_from_head
      raise ArgumentError, "Url has no head." unless doc
      doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }
      raise ArgumentError, "There are no stylesheets." if stylesheets.nil?
    end

#     def run(url, tmp_folder)
#       # Get head from url
#       doc = grab_head(url)

#       # Grab the stylesheets urls
#       stylesheets = grab_stylesheets_from_head(doc)
#       raise ArgumentError, "There are no stylesheets." if stylesheets.nil?

#       # Create array of font_files
#       input_filenames = build_array_of_font_files(stylesheets, url)

#       # Download files to tmp_folder
#       download_resources(input_filenames, tmp_folder)
#     end



#     def grab_stylesheets_from_head(doc)
#       doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }
#     end

#     # Parse each stylesheet and rip out the font file urls (eot|woff|ttf|svg)
#     def build_array_of_font_files(stylesheets, url)
#       stylesheets.map do |stylesheet| 

#         css = return_css(url, stylesheet)
        
#         # Grab all @font-face declarations
#         font_faces = css.scan(/@font-face[^}]*\}/)
#         raise ArgumentError, "There are no fonts." if font_faces.nil?

#         # Input filenames
#         font_urls = grab_font_urls(url, font_faces).flatten
#         raise ArgumentError, "There are no fonts." if font_faces.nil?

#         # Collect unique font urls
#         font_urls.uniq! if font_urls
#         font_urls.map { |file| UrlResolver.resolve(url, file) }    

#       end.flatten
#     end

#     def return_css(url, stylesheet)
#       # Resolve long url for stylesheet, //, http:// or relative
#       link = UrlResolver.resolve(url, stylesheet)

#       begin
#         # Open stylesheet using Nokogiri & beautify/split css for regex
#         css = beautify_css(Nokogiri::HTML(open(link)).to_s)

#       rescue OpenURI::HTTPError => e
#         if e.message == '404 Not Found'
#           # handle 404 error
#         else
#           raise e
#         end
#       end
#     end

#     def beautify_css(string)
#       string.split(';').join('; ')
#     end

#     # Array of font_faces
#     def grab_font_urls(url, font_faces)
#       # Grab URLS out of @font-face
#       font_faces.map do |font|

#         # Anything between the brackets
#         array = font.scan(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)

#         # If array is not empty
#         array.flatten.map { |f| f if f[/.eot|.woff|.ttf|.svg/] }.compact if array.any?
#       end
#     end

#     def get_filename(url)
#       uri = URI.parse(url)
#       File.basename(uri.path) if !uri.path.nil?
#     end

#     def read_uris_from_file(files)
#       files.map do |url|
#         url = url.strip
#         next if url == nil || url.length == 0
#         pair = { resource: url, filename: get_filename(url) }
#       end
#     end

#     def download_resources(input_filenames, tmp_folder)
#       # Create an array of uri pairs [{ resource: "x", filename: "y" }]
#       pairs = read_uris_from_file(input_filenames)

#       pairs.each do |pair|
#         filename = pair[:filename].to_s
#         resource = pair[:resource].to_s
#         unless File.exists?(filename)
#           download_resource(resource, filename, tmp_folder)
#         else
# puts "Skipping download for " + filename + ". It already exists."
#         end
#       end
#     end

#     def download_resource(resource, filename, tmp_folder)
#       uri = URI.parse(resource)

#       case uri.scheme.downcase
#       when /http|https/
#         # http_download_uri(uri, filename)
#         http_download_uri_and_write_file_to_temp(uri, filename, tmp_folder)
#       # when /ftp/
#       #   ftp_download_uri(uri, filename)
#       else
# puts "Unsupported URI scheme for resource " + resource + "."
#       end
#     end

#     def http_download_uri_and_write_file_to_temp(uri, filename, tmp_folder)
# puts "Starting HTTP download for: " + uri.to_s

#       begin
#         # We create a local representation of the remote resource
#         local_resource = local_resource_from_url(uri.to_s)

#         # We have a copy of the remote file for processing
#         local_copy_of_remote_file = local_resource.file
        
#         # Do your processing with the local file
#   puts local_copy_of_remote_file

#       ensure
#         # It's good idea to explicitly close your tempfiles
#         local_copy_of_remote_file.close
#         local_copy_of_remote_file.unlink
#       end


#       # Net::HTTP is an HTTP client API for Ruby
#       # If I am only performing a few GET requests should I try OpenURI?
# #       http_object = Net::HTTP.new(uri.host, uri.port)
# #       http_object.use_ssl = true if uri.scheme == 'https'

# #       begin

# #         # Open a connection to the server
# #         http_object.start do |http|

# #           # Make new Get request
# #           request = Net::HTTP::Get.new uri.request_uri
# #           http.read_timeout = 500

# #           # Create a Net::HTTPResponse object from that request
# #           http.request request do |response|
# # # tmp_folder.write response # Exception: 'closed stream'.
# # # response Net::HTTPOK
# # # response.body is a String

# # # puts "Uri: #{uri}"
# # # puts "Filename: #{filename}"

# #           begin
# #             extension = File.extname(filename)
# #             name      = File.basename(filename, File.extname(filename))
# # # puts "Name: #{name}"
# # # puts "Extension: #{extension}"

# #             # Create a new temp file
# #             t = Tempfile.new([name, extension])

# #             # Write string to tempfile
# #             t.write(response.body) # No such file or directory @ rb_sysopen
# # puts t.path
# # puts tmp_folder
# # # puts "tmp_folder.path: #{tmp_folder.path}"

# #             Zip::OutputStream.open(tmp_folder) do |z|
# #               z.put_next_entry(name)
# #               z.print IO.read(open(t.path))
# #             end

# #           ensure
# #             # It's good idea to explicitly close your tempfiles
# #             t.close
# #             t.unlink
# #           end






# #             # response.read_body do |chunk|
# #       #         # tmp_folder.write chunk # Exception: 'closed stream'.
# #       #         # tmp_folder.write IO.read(chunk) (Empty)

# # # puts chunk.class
# # # String

# #       #         name  = Pathname.new(uri.path).basename
# #       #         extension = Pathname.new(uri.path).extname
# #       #         t = Tempfile.new([name, extension])

# #       #         open t.path, 'w' do |io|
# #       #           response.read_body do |chunk|
# #       #             io.write chunk
# #       #           end
# #       #         end

# #       #         tmp_folder.put_next_entry(filename)
# #       #         tmp_folder.print t.write(chunk)




              

# #       #         # t = Tempfile.new([name, extension])
# #       #         # open t.path, 'w' do |io|
# #       #         #   response.read_body do |chunk|
# #       #         #     io.write chunk
# #       #         #   end
# #       #         # end

# #       #         # tmp_folder.put_next_entry(filename)

# #       #         # open t.path, "w" do |file|
# #       #         #   tmp_folder.print IO.read(open(file))
# #       #         # end
# #       #         # # tmp_folder.print t.write(chunk)
# #       #         # # tmp_folder.write t

# #       #         # t.close
# #       #         # t.unlink

# #             # end
# #           end
# #         end

# #       rescue Exception => e
# # puts "=> Exception: '#{e}'. Skipping download."
# #         return
# #       end

# puts "Stored download as " + filename + "."
# puts " "
#     end




















#     # def http_download_uri(uri, filename)
#     #   puts "Starting HTTP download for: " + uri.to_s
#     #   http_object = Net::HTTP.new(uri.host, uri.port)
#     #   http_object.use_ssl = true if uri.scheme == 'https'
#     #   begin
#     #     http_object.start do |http|
#     #       request = Net::HTTP::Get.new uri.request_uri
#     #       http.read_timeout = 500
#     #       http.request request do |response|
#     #         open filename, 'w' do |io|
#     #           response.read_body do |chunk|
#     #             io.write chunk
#     #           end
#     #         end
#     #       end
#     #     end
#     #   rescue Exception => e
#     #     puts "=> Exception: '#{e}'. Skipping download."
#     #     return
#     #   end
#     #   puts "Stored download as " + filename + "."
#     # end

#     # def ftp_download_uri(uri, filename)
#     #   puts "Starting FTP download for: " + uri.to_s + "."
#     #   dirname = File.dirname(uri.path)
#     #   basename = File.basename(uri.path)
#     #   begin
#     #     Net::FTP.open(uri.host) do |ftp|
#     #       ftp.login
#     #       ftp.chdir(dirname)
#     #       ftp.getbinaryfile(basename)
#     #     end
#     #   rescue Exception => e
#     #     puts "=> Exception: '#{e}'. Skipping download."
#     #     return
#     #   end
#     #   puts "Stored download as " + filename + "."
#     # end

  end
end