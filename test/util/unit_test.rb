require 'test_helper'

class ValidatorTest < Minitest::Test
  def test_convert_Qa_to_Zil
    qa = 1_000_000_000_000
    expected = 1
    assert_equal expected, Laksa::Util::Unit.from_qa(qa, Laksa::Util::Unit::ZIL)
  end

  def test_convert_Qa_to_Li
    qa = 1_000_000
    expected = 1
    assert_equal expected, Laksa::Util::Unit.from_qa(qa, Laksa::Util::Unit::LI)
  end

  def test_convert_Li_to_Qa
    qa = 1
    expected = 1_000_000
    assert_equal expected, Laksa::Util::Unit.to_qa(qa, Laksa::Util::Unit::LI)
  end

  def test_convert_Zil_to_Qa
    qa = 1
    expected = 1_000_000_000_000
    assert_equal expected, Laksa::Util::Unit.to_qa(qa, Laksa::Util::Unit::ZIL)
  end

  def test_from_qa_with_negative_number
    qa = -1_000_000_000_000
    expected = -1
    assert_equal expected, Laksa::Util::Unit.from_qa(qa, Laksa::Util::Unit::ZIL)
  end

  def test_from_qa_with_pack
    qa = 1_000_000_000_001
    expected = 1
    assert_equal expected, Laksa::Util::Unit.from_qa(qa, Laksa::Util::Unit::ZIL, true)
  end

  def test_to_qa_with_negative_number
    qa = -1
    expected = -1_000_000_000_000
    assert_equal expected, Laksa::Util::Unit.to_qa(qa, Laksa::Util::Unit::ZIL)
  end
end