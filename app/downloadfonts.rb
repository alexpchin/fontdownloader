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

        # Create a directory name for this download
        target_dir_name = Date.today.strftime('%y%m%d')

        # Create securehex to add to this download
        hex = SecureRandom.hex

        # Create unique(ish) directory name using target_dir_name and hex
        target_dir_name = "#{target_dir_name}-#{hex}"

        # Download the fonts with Sidekiq
        FontWorker.perform_async(input_filenames, target_dir_name)

        # Return the zip name to controller
        "#{target_dir_name}.zip"

      else
        return false
      end
    end
  end   
end