require "../src/build"
require "./spec_helper"

describe :build do
  it "make directory build_dir" do
    dir = Crun.build_dir

    File.directory?(dir).should eq(true)
    File.readable?(dir).should eq(true)
    File.executable?(dir).should eq(true)
    File.writable?(dir).should eq(true)
  end

  it "define build_path" do
    file_path = Crun.build_path

    File.dirname(file_path).should eq(Crun.build_dir)
  end
end
