require "test_helper"

class KeyToolTest < Minitest::Test
  def test_generate_private_key
    private_key = Laksa::Crypto::KeyTool.generate_private_key
    assert_equal 64, private_key.length
  end

  def test_generate_random_bytes
    random_bytes = Laksa::Crypto::KeyTool.generate_random_bytes(32)
    assert_equal 32, random_bytes.length
  end

  def test_get_public_key
    private_key = "24180e6b0c3021aedb8f5a86f75276ee6fc7ff46e67e98e716728326102e91c9";
    key_tool = Laksa::Crypto::KeyTool.new(private_key)
    public_key = key_tool.get_public_key(false);
    assert_equal "04163fa604c65aebeb7048c5548875c11418d6d106a20a0289d67b59807abdd299d4cf0efcf07e96e576732dae122b9a8ac142214a6bc133b77aa5b79ba46b3e20", public_key.downcase

    private_key = "b776d8f068d11b3c3f5b94db0fb30efea05b73ddb9af1bbd5da8182d94245f0b";
    key_tool = Laksa::Crypto::KeyTool.new(private_key)
    public_key = key_tool.get_public_key(false);
    assert_equal "04cfa555bb63231d167f643f1a23ba66e6ca1458d416ddb9941e95b5fd28df0ac513075403c996efbbc15d187868857e31cf7be4d109b4f8cb3fd40499839f150a", public_key.downcase

    private_key = "e19d05c5452598e24caad4a0d85a49146f7be089515c905ae6a19e8a578a6930";
    key_tool = Laksa::Crypto::KeyTool.new(private_key)
    public_key = key_tool.get_public_key(true);
    assert_equal "0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a", public_key.downcase
  end

  def test_get_address
    private_key = "B4EB8E8B343E2CCE46DB4E7571EC1D9654693CCA200BC41CC20148355CA62ED9";
    key_tool = Laksa::Crypto::KeyTool.new(private_key)
    address = key_tool.get_address;
    assert_equal "4baf5fada8e5db92c3d3242618c5b47133ae003c", address
  end

  def test_get_address_from_public_key
    public_key = "0314738163b9bb67ad11aa464fe69a1147df263e8970d7dcfd8f993ddd39e81bd9";
    address = Laksa::Crypto::KeyTool.get_address(public_key);
    assert_equal "4baf5fada8e5db92c3d3242618c5b47133ae003c", address
  end
end