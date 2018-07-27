require "./version"

if ARGV[0]?.try { |arg| arg.match(/^-(v|-version)$/) }
  STDOUT.puts "crun #{Crun::VERSION}"
  exit(0)
end
