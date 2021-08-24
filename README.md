[![Travis-CI Build Status](https://app.travis-ci.com/Val/crun.svg?branch=master)](https://app.travis-ci.com/Val/crun)
[![CircleCI Build Status](https://circleci.com/gh/Val/crun.svg?style=shield)](https://circleci.com/gh/Val/crun)
[![Release](https://img.shields.io/github/release/Val/crun.svg?maxAge=360)](https://github.com/Val/crun/releases)

# crun
Crystal Run : shebang wrapper for Crystal

**crun** is a tool enabling one to put a "bang line" in the source code of
a Crystal program to run it, or to run such a source code file explicitly.
It was inspired by [gorun](https://github.com/erning/gorun) and created in
an attempt to make experimenting with Crystal more appealing to people
used to Ruby and similar languages which operate most visibly with source
code.

## Example

As an example, copy the following content to a file named "hello.cr" (or
"hello", if you prefer):

```Crystal
#!/usr/bin/env crun

puts "Hello world"
```

Then, simply run it:


```
$ chmod +x hello.cr
$ ./hello.cr
Hello world!
```

## Features

**crun** will:

  * write files under a safe directory in `$CRUN_CACHE_PATH`,
    `$XDG_CACHE_HOME/crun`, `~/.cache/crun`, `~/.cache/.crun` or `.crun`
    in this order, so that the actual script location isn't touched
    (may be read-only)
  * avoid races between parallel compilation of the same file
  * automatically clean up old compiled files that remain unused for
    some time, by default each 7 days but can be overriden by setting
    `CLEAN_CACHE_DAYS`
  * replace the process rather than using a child
  * pass arguments to the compiled application properly
  * handle well shards with comment containing `dependencies` of a
    classical `shards.yml` file. Anchors used can be changed by settings
    `CRUN_SHARDS_START_ANCHOR` (default: `---`) and
    `CRUN_SHARD_END_ANCHOR` (default: `...`).

## Shards support example

```Crystal
#!/usr/bin/env crun
# ---
# minitest:
#   github: ysbaddaden/minitest.cr
# ...

class Foo
  def bar
    "baz"
  end
end

require "minitest/autorun"

class FooTest < Minitest::Test
  def foo
    @foo ||= Foo.new
  end

  def test_that_foo_bar_baz
    assert_equal "baz", foo.bar
  end
end

describe Foo do
  let(:foo) { Foo.new }

  describe "when asked about bar" do
    it "must respond baz" do
      foo.bar.must_equal("baz")
    end
  end
end

```

## Where are the compiled files kept?

They are kept under `$CRUN_CACHE_PATH`, `$XDG_CACHE_HOME/crun`,
`~/.cache/crun`, `~/.cache/.crun` or `.crun` in this order, in a directory
named after the hostname and the slug of the source file name.

You can remove these files, but there's no reason to do this. These
compiled files will be garbage collected by **crun** itself after a while
once they stop being used. This is done in a fast and safe way so that
concurrently executing scripts will not fail to execute.

## How to build and install crun from source

```Shell
make release
make install
```

You can change `PREFIX` or `BINDIR` environment variable, see `Makefile`

## Usage

```Shell
usage: crun <source file> [...]
```

# Add Linux binfmt support

``` Shell
echo ':crystal:E::cr::/usr/local/bin/crun:OC' \
  | sudo tee /proc/sys/fs/binfmt_misc/register
```
or
```Shell
make binfmt
```

## Development

### Install Git pre-commit hook

```Shell
make githook
```

### Makefile help

```Shell
> make
targets:
  auto            Run tests suite continuously on writes
  binfmt          Add Linux binfmt support
  check           Run Ameba static code check
  clean           Remove crun builded binary
  clobber         Clean and remove editor backup files (*~)
  crun            Build crun binary
  format          Run Crystal format tool
  githook         Install Git pre-commit hook
  help            Show this help
  install         Install crun binary
  release         Build crun binary
  spec            Run crun specs
  tests           Run tests suite
  todo            Show fixme and todo comments
  uninstall       Uninstall crun binary
```

### OsX (for fancy autotests / continuous testing)

```Shell
brew tap veelenga/tap
brew install ameba crystal fswatch imagemagick terminal-notifier
```
or
```Shell
make osx
```

### Debian/Ubuntu (for fancy autotests / continuous testing)

```Shell
apt install -y -q inotify-tools libnotify-bin
```

## Contributing

1. Fork it (<https://github.com/Val/crun/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Val](https://github.com/Val) Laurent Vallar - creator, maintainer
- [bew](https://github.com/bew) Benoit de Chezelles
