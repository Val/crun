require "./config"
require "./crun"
require "./errors"
require "./version"

if ARGV[0]?.try { |arg| arg.match(/^-(v|-version)$/) }
  STDOUT.puts "crun #{Crun::VERSION}"
  exit(0)
end

begin
  Crun.run
rescue error : Crun::Error
  STDERR.puts "#{error.class}: #{error.message}"
  STDERR.puts("usage: crun <source file> [...]")
  exit(1)
end
