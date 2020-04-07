require "file_utils"

module Crun
  def self.cache_path=(path : String)
    unless File.directory?(path)
      raise CacheError.new("Invalid cache_path, not a dir.: #{path.inspect}")
    end

    unless File.executable?(path) && File.writable?(path)
      raise CacheError.new("Invalid cache_path access rights: #{path.inspect}")
    end

    @@cache_path = path
  end

  def self.cache_path
    @@cache_path ||= find_or_create_cache_path
  end

  def self.clean_cache
    pathes = Dir.glob([File.join(cache_path, "*")])
      .each_with_object({} of Time => Array(String)) do |path, hash|
        modification_time = File.info(path).modification_time.to_utc
        hash[modification_time] ||= [] of String
        hash[modification_time] << path
      end

    return if pathes.empty?

    limit = Time.utc - Time::Span.new(CLEAN_CACHE_DAYS, 0, 0, 0)

    pathes.keys.select { |key| key < limit }.sort_by { |key| key }.each do |key|
      pathes[key].each { |path| FileUtils.rm_rf(path) }
    end
  end

  private BUILD_DIR     = "crun"
  private DOT_BUILD_DIR = ".#{BUILD_DIR}"

  private def self.cache_path_candidates
    local_cache = ENV["HOME"]?.try { |home| File.join(home, ".cache") }

    [
      ENV["CRUN_CACHE_PATH"]?,
      ENV["XDG_CACHE_HOME"]?.try { |cache| File.join(cache, BUILD_DIR) },
      local_cache.try { |path| File.join(path, BUILD_DIR) },
      local_cache.try { |path| File.join(path, DOT_BUILD_DIR) },
      File.join(Dir.current, DOT_BUILD_DIR),
    ]
  end

  private def self.find_or_create_cache_path
    cache_path_candidates.each do |candidate|
      next unless candidate

      path = File.expand_path(candidate)
      return path if File.directory?(path)

      begin
        Dir.mkdir_p(path)
        return path
      rescue File::Error
      end
    end

    raise CacheError.new("Failed to find or create cache directory")
  end
end
