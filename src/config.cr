module Crun
  SOURCE = ARGV[0]?.try { |source| File.expand_path(source) } || ""
end
