require "../src/shards"
require "./spec_helper"

describe :shards_config_path do
  it "should point to shard.yml file" do
    Crun.shards_config_path.should match(/\/shard.yml/)
  end
end
