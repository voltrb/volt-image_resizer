require 'image_resizer/lib/disk_file_cache'
require 'image_resizer/lib/downloader'

module ImageResizer
  class ResizerController < Volt::HttpController
    include Downloader
    RESIZED_PATH  = "tmp/resized_images"

    # Create the resize_images folder if it does not exist
    FileUtils.mkdir_p(RESIZED_PATH)

    RESIZED_CACHE = DiskFileCache.new(RESIZED_PATH, 1000)

    def index
      image_url = params._image_url

      download_path = download_cached(image_url)

      height = params._height.to_i
      width = params._width.to_i
      crop = params._crop
      key = "#{height}/#{width}/#{crop}/#{image_url}"
      resize_path = RESIZED_CACHE.fetch(key) do |resize_path|
        resize_image(download_path, resize_path, height, width, crop)
      end

      resize_cache_time = Volt.config.resize_cache_time || 3600 # 1 hour default
      response_headers['Cache-Control'] = "public, max-age=#{resize_cache_time}"
      send_file(resize_path)
    end


    private

    # Resizes the image to the desired h/w/crop, returns the tmp path
    def resize_image(download_path, resize_path, height, width, crop)
      `convert #{download_path.inspect} -resize "#{height}x#{width}" #{resize_path.inspect}`
    end
  end
end
