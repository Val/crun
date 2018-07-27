module Crun
  @@build_dir : String | Nil

  def self.build_path
    @@build_path ||= "#{build_dir}/#{SOURCE_FILENAME}"
  end

  def self.build_dir
    @@build_dir ||= File.join(
      cache_path,
      "#{System.hostname}_#{SOURCE.gsub(/[^a-zA-Z0-9]/, "_")}"
    ).tap { |path| Dir.mkdir(path) unless File.directory?(path) }
  end
end
