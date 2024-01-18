require "env"

module Crun
  def self.run
    raise NoArgumentError.new if SOURCE.empty?

    unless File.exists?(SOURCE) && File.readable?(SOURCE)
      raise InvalidSourceError.new
    end

    compile_error_hash = with_lock do
      channel = Channel(Nil | ErrorHash).new

      spawn { channel.send(compile) }

      clean_cache

      channel.receive
    end

    if compile_error_hash
      raise BuildError.new(
        <<-EOBUILDERROR
        Build failed: #{compile_error_hash[:command]}

        STDOUT:
        #{compile_error_hash[:stdout]}

        STDERR:
        #{compile_error_hash[:stderr]}
        EOBUILDERROR
      )
    end

    env = ENV.to_h.tap do |e|
      e["PROGRAM_NAME"] = [SOURCE_FILENAME, ARGS].flatten.join(" ")
    end

    Process.exec(build_path, ARGS, env: env)
  end
end
