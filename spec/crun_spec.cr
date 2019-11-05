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
    env: {
      "HOME"            => ENV.fetch("HOME"),
      "CRUN_CACHE_PATH" => SPEC_LOCAL_CACHE_PATH,
      "CRYSTAL_SPEC"    => "1",
    },
    clear_env: false,
    shell: true,
    input: input,
    output: output,
    error: error,
    chdir: ROOT
  )
end

def build_error_regex(path)
  <<-EOREGEX
  ^Crun::BuildError: Build failed: crystal build --debug --error-on-warnings \
--error-trace -o .+ #{Regex.escape(path)}

  STDOUT:
  EOREGEX
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
    %w[/nonexistant /proc/slabinfo].each do |path|
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

  it "fail and print usage when build unsuccessful" do
    tempfile = File.tempfile("foo") do |file|
      file.puts("puts 'invalid crystal code'")
    end

    file_path = tempfile.path

    output, error = IO::Memory.new, IO::Memory.new

    status = crun(args: [file_path], error: error, output: output)

    output.empty?.should eq(true)

    error.to_s.should(match(/#{build_error_regex(file_path)}/))
    status.success?.should eq(false)

    output.close
    error.close
  ensure
    tempfile.delete if tempfile
  end

  it "works with samples" do
    Dir.glob(File.join(ROOT, "spec/samples/*.cr")).each do |sample_path|
      sample_path_base = sample_path.gsub(/\.cr$/, "")
      args_path = "#{sample_path_base}.args"
      stdout_path = "#{sample_path_base}.stdout"
      stderr_path = "#{sample_path_base}.stderr"

      has_args = File.exists?(args_path)
      has_stdout = File.exists?(stdout_path)
      has_stderr = File.exists?(stderr_path)

      args = has_args ? File.read(args_path).chomp.split("\n") : [] of String
      stdout = has_stdout ? File.read(stdout_path) : ""
      stderr = has_stderr ? File.read(stderr_path) : ""

      output, error = IO::Memory.new, IO::Memory.new

      status = crun(
        args: [sample_path, args].flatten,
        error: error,
        output: output
      )

      output.to_s.should(eq(stdout)) if has_stdout
      error.to_s.should(eq(stderr)) if has_stderr

      status.success?.should(eq(sample_path.match(/false\.cr$/).nil?))

      shards_config_path =
        File.join(Crun.cache_path, Crun.build_name(sample_path), "shard.yml")

      if File.exists?(shards_config_path) # check shard.yml not rebuilded
        modification_time = File.info(shards_config_path).modification_time

        status = crun(
          args: [sample_path, args].flatten,
          error: error,
          output: output
        )

        status.success?.should(eq(sample_path.match(/false\.cr$/).nil?))

        File.info(shards_config_path)
          .modification_time
          .should(eq(modification_time))
      end

      output.close
      error.close
    end
  end

  it "works with pipe samples" do
    Dir.cd(PIPE_SAMPLES_DIR) do
      Dir.glob(File.join(PIPE_SAMPLES_DIR, "*.sh")).each do |sample_path|
        input = Process::Redirect::Pipe
        output, error = IO::Memory.new, IO::Memory.new

        status = Process.run(
          command: "sh",
          args: [sample_path],
          env: {
            "HOME"            => ENV.fetch("HOME"),
            "CRUN_CACHE_PATH" => SPEC_LOCAL_CACHE_PATH,
            "CRYSTAL_SPEC"    => "1",
            "PATH"            => [
              ROOT,
              PIPE_SAMPLES_DIR,
              ENV.fetch("PATH"),
            ].compact.join(":"),
          },
          clear_env: true,
          shell: true,
          input: input,
          output: output,
          error: error,
          chdir: PIPE_SAMPLES_DIR,
        )

        error.empty?.should eq(true)
        status.success?.should(eq(true))
      end
    end
  end
end
