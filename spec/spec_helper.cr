require "../src/cache"
require "../src/config"
require "../src/errors"
require "spec"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

SPEC_LOCAL_CACHE_PATH = File.tempfile("crun_spec_local_cache").path
File.delete(SPEC_LOCAL_CACHE_PATH)
Dir.mkdir(SPEC_LOCAL_CACHE_PATH)

Crun.cache_path = SPEC_LOCAL_CACHE_PATH

at_exit { FileUtils.rm_rf(SPEC_LOCAL_CACHE_PATH) }
