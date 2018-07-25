require "./spec_helper"
require "../src/version"

unless File.executable?(File.join(ROOT, "crun"))
  print "crun build needed… "
  if Dir.cd(ROOT) { system("make crun") }
    puts "\033[1;49;92mdone\033[0m"
  else
    puts "\033[1;49;91mfailed\033[0m"
    exit(1)
  end
end

def crun(args : Array(String) = [] of String,
         env : Process::Env = nil,
         input : Process::Stdio = Process::Redirect::Pipe,
         output : Process::Stdio = Process::Redirect::Pipe,
         error : Process::Stdio = Process::Redirect::Pipe)
  Process.run(
    command: "./crun",
    args: args,
    env: {"HOME" => ENV.fetch("HOME")},
    clear_env: true,
    shell: true,
    input: input,
    output: output,
    error: error,
    chdir: ROOT
  )
end

describe :crun do
  it "show version" do
    output, error = IO::Memory.new, IO::Memory.new

    status = crun(error: error, output: output)

    error.to_s.should eq("")
    output.to_s.should eq("crun #{Crun::VERSION}\n")
    error.empty?.should eq(true)
    status.success?.should eq(true)

    output.close
    error.close
  end
end
