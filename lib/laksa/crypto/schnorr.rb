require 'secp256k1'
require 'digest'
require 'openssl'

module Laksa
  module Crypto
    class Schnorr
      include Secp256k1

      def initialize()
      end

      def self.sign(message, private_key)
        is_raw = private_key.length == 32 ? true : false
        pk = PrivateKey.new(privkey: private_key, raw: is_raw)
        sig = Utils.encode_hex(pk.ecdsa_serialize_compact(pk.ecdsa_sign message)).upcase
      end

      def self.verify(message, sig, public_key)
        pubkey = PublicKey.new
        pubkey.deserialize Utils.decode_hex(public_key)

        r = sig.r
        r_bn = OpenSSL::BN.new(r.to_i(16))

        s = sig.s
        s_bn = OpenSSL::BN.new(s, 16)

        group = OpenSSL::PKey::EC::Group.new('secp256k1')
        pubkey_bn = OpenSSL::BN.new(public_key, 16)
        pubkey_point = OpenSSL::PKey::EC::Point.new(group, pubkey_bn)
        
        q = pubkey_point.mul(r_bn, s_bn)

        sha256 = Digest::SHA256.new
        sha256 << q.to_octet_string(:compressed)
        sha256 << pubkey_point.to_octet_string(:compressed)
        sha256 << Utils.decode_hex(message)

        n_bn = OpenSSL::BN.new('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16)
        h_bn = OpenSSL::BN.new(sha256.hexdigest, 16) % n_bn

        h_bn.eql?(r_bn)
      end
    end

    class Signature
      attr_reader :r, :s
      def initialize(r, s)
        @r = r
        @s = s
      end
    end
  end
end