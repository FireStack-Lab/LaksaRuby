require "test_helper"

class SchnorrTest < Minitest::Test
  def test_sign
    ds = datas['datas']

    ds.each do |d|
      message = d[0]
      public_key = d[1]
      private_key = d[2]
      r = d[4]
      s = d[5]

      sig = Laksa::Crypto::Schnorr.sign(message, private_key)

      result = Laksa::Crypto::Schnorr.verify(message, sig, public_key)
      assert result
    end
  end

  def test_verify
    ds = datas['datas']

    ds.each do |d|
      message = d[0]
      public_key = d[1]
      private_key = d[2]
      r = d[4]
      s = d[5]

      result = Laksa::Crypto::Schnorr.verify(message, "#{r}#{s}", public_key)
      assert result
    end
  end

  def datas
    @datas = JSON.parse File.read(File.expand_path('../../fixtures/schnorr.json', __FILE__))
  end
end