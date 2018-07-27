module Crun
  def self.run
    raise NoArgumentError.new if SOURCE.empty?
  end
end
