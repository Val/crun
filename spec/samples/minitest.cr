# ---
# minitest:
#   github: ysbaddaden/minitest.cr
#   version: <= 0.4.0
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
