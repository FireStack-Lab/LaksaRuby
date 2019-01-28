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

      signature = Laksa::Crypto::Signature.new(r, s)
      result = Laksa::Crypto::Schnorr.verify(message, sig, public_key)
      assert result
    end
  end

  # def test_verify
  #   ds = datas['datas']

  #   ds.each do |d|
  #     message = d[0]
  #     public_key = d[1]
  #     private_key = d[2]
  #     r = d[4]
  #     s = d[5]

  #     signature = Laksa::Crypto::Signature.new(r, s)
  #     result = Laksa::Crypto::Schnorr.verify(message, signature, public_key)
  #     assert result
  #   end
  # end
  
  # def test_demo
  #   ds = datas['datas'][0...1]

  #   ds.each do |d|
  #     message = d[0]
  #     public_key = d[1]
  #     private_key = d[2]
  #     r = d[4]
  #     s = d[5]

  #     sig = "#{r}#{s}"
  #     puts "r:#{r}, s:#{s}"
  #     puts "#{r}#{s}".length
  #     result = Laksa::Crypto::Schnorr.verify(message, sig, public_key)
  #     puts result
  #     # assert result
  #   end
  # end

  def datas
    @datas = JSON.parse File.read(File.expand_path('../../fixtures/schnorr.json', __FILE__))
  end
end