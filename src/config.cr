module Crun
  SOURCE = ARGV[0]?.try { |source| File.expand_path(source) } || ""
  CLEAN_CACHE_DAYS = ENV["CRUN_CLEAN_CACHE_DAYS"]?.try { |v| v.as?(Int32) } || 1
end
