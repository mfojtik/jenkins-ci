require 'bundler'

require 'minitest/autorun'

class TestSample < Minitest::Test

  def test_title_is_treehouse
    assert_equal "Foo", "Foo"
  end

end
