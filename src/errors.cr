module Crun
  class Error < ::Exception
  end

  class NoArgumentError < Error
    def initialize(@message = "Missing at least one argument")
    end
  end

  class InvalidSourceError < Error
    def initialize(@message = "Cannot read #{SOURCE} Crystal source")
    end
  end

  class CacheError < Error
  end
end
