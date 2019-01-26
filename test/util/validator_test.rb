require 'test_helper'

class ValidatorTest < Minitest::Test
  def test_public_key?
    public_key = '039E43C9810E6CC09F46AAD38E716DAE3191629534967DC457D3A687D2E2CDDC6A'
    assert Laksa::Util::Validator.public_key?(public_key)
    assert !Laksa::Util::Validator.public_key?(public_key[0..-2])
  end

  def test_private_key?
    private_key = '24180e6b0c3021aedb8f5a86f75276ee6fc7ff46e67e98e716728326102e91c9'
    assert Laksa::Util::Validator.private_key?(private_key)
    assert !Laksa::Util::Validator.private_key?(private_key[0..-2])
  end

  def test_public_key?
    address = 'B5C2CDD79C37209C3CB59E04B7C4062A8F5D5271'
    assert Laksa::Util::Validator.address?(address)
    assert !Laksa::Util::Validator.address?(address[0..-2])
  end

  def test_signature?
    signature = '3AF3D288E830E96FF8ED0769F45ABDA774CD989E2AE32EF9E985C8505F14FF98E191EB14A70B5B53ADA45AFFF4A04578F5D8BB2B1C8A22985EA159B53826CDE7'
    assert Laksa::Util::Validator.signature?(signature)
    assert !Laksa::Util::Validator.signature?(signature[0..-2])
  end

  def test_checksum_address?
    checksum_address = '0x4BAF5faDA8e5Db92C3d3242618c5B47133AE003C'
    assert Laksa::Util::Validator.checksum_address?(checksum_address)
    assert !Laksa::Util::Validator.checksum_address?(checksum_address[0..-2])
    assert !Laksa::Util::Validator.checksum_address?(checksum_address.upcase)
  end
end