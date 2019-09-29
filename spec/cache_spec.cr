require "./spec_helper"

describe :cache do
  it "clean old pathes" do
    spec_recent_path = File.join(SPEC_LOCAL_CACHE_PATH, "recent")
    spec_old_path = File.join(SPEC_LOCAL_CACHE_PATH, "old")

    Dir.mkdir(spec_recent_path)
    Dir.mkdir(spec_old_path)

    File.touch(spec_old_path, Time.utc - (Crun::CLEAN_CACHE_DAYS + 1).days)

    Crun.clean_cache

    File.directory?(spec_recent_path).should eq(true)
    File.exists?(spec_old_path).should eq(false)
  end
end
