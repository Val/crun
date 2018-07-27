module Crun
  def self.run
    raise NoArgumentError.new if SOURCE.empty?

    unless File.exists?(SOURCE) && File.readable?(SOURCE)
      raise InvalidSourceError.new
    end
  end
end
