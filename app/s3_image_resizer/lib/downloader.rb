require 'uri'
require 'net/http'
require 'fileutils'
require 's3_image_resizer/lib/disk_file_cache'

module S3ImageResizer
  module Downloader
    ORIGINAL_PATH = "tmp/resize_original_images"
    FileUtils.mkdir_p(ORIGINAL_PATH)
    DOWNLOAD_CACHE = DiskFileCache.new(ORIGINAL_PATH, 1000)

    # Downloads the image to a temp file, returns the path to the temp file.
    def download_image_to_temp(image_url, tmp_path)
      ext = File.extname(image_url)

      # Download the image
      uri = URI(image_url)

      Net::HTTP.start(uri.host, uri.port, :use_ssl => (uri.scheme == 'https')) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        http.request request do |response|
          File.open(tmp_path, 'wb') do |io|
            response.read_body do |chunk|
              io.write chunk
            end
          end
        end
      end
    end

    # Downloads or pulls the file from cache and returns the path to the file
    # locally.  Handles clearing the cache later.
    def download_cached(image_url)
      DOWNLOAD_CACHE.fetch(image_url) do |download_path|
        download_image_to_temp(image_url, download_path)
      end
    end
  end
end