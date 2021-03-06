require "../src/cache"
require "../src/config"
require "../src/errors"

ROOT             = File.expand_path(File.join(File.dirname(__FILE__), ".."))
PIPE_SAMPLES_DIR = File.join(ROOT, "spec", "samples", "pipe")

SPEC_LOCAL_CACHE_PATH = File.tempfile("crun_spec_local_cache").path
File.delete(SPEC_LOCAL_CACHE_PATH)
Dir.mkdir(SPEC_LOCAL_CACHE_PATH)

Crun.cache_path = SPEC_LOCAL_CACHE_PATH

at_exit { FileUtils.rm_rf(SPEC_LOCAL_CACHE_PATH) }

require "spec"
