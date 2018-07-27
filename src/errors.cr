module Crun
  class Error < ::Exception
  end

  class NoArgumentError < Error
    def initialize(@message = "Missing at least one argument")
    end
  end
end
