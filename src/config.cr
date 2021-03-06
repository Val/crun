module Crun
  SOURCE          = ARGV[0]?.try { |source| File.expand_path(source) } || ""
  SOURCE_FILENAME = File.basename(SOURCE)

  ARGS = ARGV.size > 1 ? ARGV[1..ARGV.size] : [] of String

  CLEAN_CACHE_DAYS = ENV["CRUN_CLEAN_CACHE_DAYS"]?.try { |v| v.as?(Int32) } || 7
end
