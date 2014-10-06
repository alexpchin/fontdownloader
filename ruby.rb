require 'rubygems'
require 'nokogiri' 
require 'css_parser'
require 'open-uri'
require 'net/http'
require 'net/ftp'
require 'uri'
require 'date'

require 'pry-byebug'
require 'sinatra'
require 'sinatra/reloader' if development?

def get_long_url(url, short_url)
  if !short_url[/^http/]
    if short_url[/^\/\//]
      "http:#{short_url}"
    else 
      url + short_url
    end
  else
    short_url
  end
end

def create_directory(dirname)
  unless Dir.exists?(dirname)
    Dir.mkdir(dirname)
  else
    puts "Skipping creating directory " + dirname + ". It already exists."
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
 
def main(urls)
  uris = read_uris_from_file(urls)
  target_dir_name = Date.today.strftime('%y%m%d')
  create_directory(target_dir_name)
  Dir.chdir(target_dir_name)
  puts "Changed directory: " + Dir.pwd
  download_resources(uris)
end

def run(url)
  page = Nokogiri::HTML(open(url))
  doc =  page.xpath("/html/head")
  stylesheets = doc.xpath('//link[@rel="stylesheet"]').map { |link| link['href'] }

  stylesheets.each do |s| 
    begin
      link = get_long_url(url, s)
      puts link
      css = Nokogiri::HTML(open(link)).to_s
      input_filenames = css.split(';').join('; ').scan(/src:url(\(.*?\.(?:eot|woff|ttf|svg))/).map do |s| 
        v = s[0].delete!('()"')
        get_long_url(url, s[0]) if v
      end
      
      main(input_filenames)

    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        # handle 404 error
      else
        raise e
      end
    end
  end
end

get '/' do
  run(url)
end

post '/' do
  run params[:url]
end