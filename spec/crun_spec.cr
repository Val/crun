require "../src/version"
require "./spec_helper"

unless File.executable?(File.join(ROOT, "crun"))
  puts "crun build needed… "

  unless Dir.cd(ROOT) { system("make crun") }
    puts "build \033[1;49;91mfailed\033[0m"
    exit(1)
  end

  puts "build \033[1;49;92mdone\033[0m"
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
  usage = "usage: crun <source file> [...]\n"

  it "show version" do
    %w[-v --version].each do |arg|
      output, error = IO::Memory.new, IO::Memory.new

      status = crun(args: [arg], error: error, output: output)

      error.to_s.should eq("")
      output.to_s.should eq("crun #{Crun::VERSION}\n")
      error.empty?.should eq(true)
      status.success?.should eq(true)

      output.close
      error.close
    end
  end

  it "fail and print usage when no arguments" do
    output, error = IO::Memory.new, IO::Memory.new

    status = crun(error: error, output: output)

    output.empty?.should eq(true)
    error.to_s.should(
      eq("Crun::NoArgumentError: Missing at least one argument\n#{usage}")
    )
    status.success?.should eq(false)

    output.close
    error.close
  end

  it "fail and print usage when invalid source argument" do
    %w[/nonexistant /etc/shadow].each do |path|
      output, error = IO::Memory.new, IO::Memory.new

      status = crun(args: [path], error: error, output: output)

      output.empty?.should eq(true)
      error.to_s.should(
        eq(
          <<-EOSTDOUT
          Crun::InvalidSourceError: Cannot read #{path} Crystal source
          #{usage}
          EOSTDOUT
        )
      )
      status.success?.should eq(false)

      output.close
      error.close
    end
  end
end
