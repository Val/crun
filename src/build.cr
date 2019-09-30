module Crun
  @@build_dir : String | Nil

  def self.build_path
    @@build_path ||= "#{build_dir}/#{SOURCE_FILENAME}.crystal"
  end

  def self.build_name(path : String)
    "#{System.hostname}_#{path.gsub(/[^a-zA-Z0-9]/, "_")}"
  end

  def self.build_dir
    @@build_dir ||=
      File.join(cache_path, build_name(SOURCE))
        .tap { |path| Dir.mkdir(path) unless File.directory?(path) }
  end

  private def self.compile : ErrorHash | Nil
    return if build?

    hash = nil

    hash = Dir.cd(build_dir) do
      if shards_yaml
        current =
          File.read(shards_config_path) if File.exists?(shards_config_path)

        # build shard.yml and install shards if none or outdated
        if current.nil? || !current.match(/#{shards_yaml}/m)
          build_shards_config
          hash = build_subprocess("shards", %w[install])
        end
      end

      hash || build_subprocess("crystal", ["build", "-o", build_path, SOURCE])
    end

    return hash if hash
  end

  private def self.build?
    File.exists?(build_path) && \
       File.info(build_path).modification_time > \
        File.info(SOURCE).modification_time
  end

  private def self.build_subprocess(command : String,
                                    args : Array(String) = [] of String)
    input = IO::Memory.new
    output = IO::Memory.new
    error = IO::Memory.new

    status = Process.run(
      command: command,
      args: args,
      clear_env: false,
      shell: true,
      input: input,
      output: output,
      error: error
    )

    return if status.success?

    output_str = output.to_s
    error_str = error.to_s

    input.close
    output.close
    error.close

    {
      command: [command, args].flatten.join(" "),
      stdout:  output_str,
      stderr:  error_str,
    }
  end
end
