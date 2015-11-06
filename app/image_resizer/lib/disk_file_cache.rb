# A simple LRU disk file cache
require 'lrucache'
require 'fileutils'
require 'securerandom'

class DiskFileCache
  def initialize(path, size=1000)
    @path = File.expand_path(path).chomp('/')
    @cache = LRUCache.new(
      :max_size => size,
      :eviction_handler => lambda { |path| delete_file(path) }
    )
  end

  def fetch(key)
    path = @cache[key]

    return path if path

    ext = File.extname(key)

    path = tmp_file(ext)
    yield(path) if block_given?
    @cache[key] = path

    return path
  end

  def tmp_file(ext)
    "#{@path}/#{SecureRandom.hex}#{ext}"
  end

  private
  def delete_file(path)
    # Delete the file since it was evicted
    FileUtils.rm(path)
  end
end
