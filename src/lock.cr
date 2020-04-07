module Crun
  @@lockfile : File | Nil

  def self.lockfile_path
    lockfile.path
  end

  def self.with_lock(&block)
    lockfile.flock_exclusive { yield }
  ensure
    unlock
  end

  private def self.lockfile
    @@lockfile ||= File.new("#{build_path}.lock", "w").tap(&.puts(Process.pid))
  end

  private def self.unlock
    lockfile.flock_unlock
    begin
      File.delete(lockfile.path)
    rescue error : File::Error
      raise error unless error.class == File::NotFoundError
    end
    @@lockfile = nil
  end
end
