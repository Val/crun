require "../src/lock"
require "./spec_helper"

describe :lock do
  it "accept a block" do
    object = Random::Secure.hex

    Crun.with_lock { object }.should eq(object)
  end

  it "locks exclusively lockfile" do
    Crun.with_lock do
      path = Crun.lockfile_path

      File.exists?(path).should eq(true)

      expect_raises(IO::Error) do
        File.new(path).flock_exclusive(false)
      end
    end
  end
end
