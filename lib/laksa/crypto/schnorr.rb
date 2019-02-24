require 'secp256k1'
require 'digest'
require 'openssl'

module Laksa
  module Crypto
    class Schnorr
      include Secp256k1

      N = OpenSSL::BN.new('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16)
      G = OpenSSL::BN.new('79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798', 16)

      def initialize
      end

      # sign
      #
      # @param {Buffer} msg
      # @param {Buffer} key
      def self.sign(message, private_key)
        k = Utils.encode_hex SecureRandom.random_bytes(32)
        k_bn = OpenSSL::BN.new(k, 16)

        self.try_sign(message, private_key, k_bn)
      end

      # trySign
      #
      # @param {Buffer} message - the message to sign over
      # @param {BN} privateKey - the private key
      # @param {BN} k_bn - output of the HMAC-DRBG
      #
      # @returns {Signature | null =>}
      def self.try_sign(message, private_key, k_bn)
        group = OpenSSL::PKey::EC::Group.new('secp256k1')

        public_key = KeyTool.get_public_key_from_private_key(private_key)

        pubkey_bn = OpenSSL::BN.new(public_key, 16)
        pubkey_point = OpenSSL::PKey::EC::Point.new(group, pubkey_bn)

        q_point = pubkey_point.mul(0, k_bn)

        r_bn = hash(q_point, pubkey_point, message) % N

        prikey_bn = OpenSSL::BN.new(private_key, 16)

        s_bn = r_bn * prikey_bn % N

        s_bn = k_bn.mod_sub(s_bn, N)

        Signature.new(r_bn.to_s(16), s_bn.to_s(16))
      end


      # Verify signature.
      #
      # @param {Buffer} message
      # @param {Buffer} sig
      # @param {Buffer} public_key
      #
      # @returns {boolean}
      #
      # 1. Check if r,s is in [1, ..., order-1]
      # 2. Compute Q = sG + r*kpub
      # 3. If Q = O (the neutral point), return 0;
      # 4. r' = H(Q, kpub, m)
      # 5. return r' == r
      def self.verify(message, sig, public_key)
        pubkey = PublicKey.new
        pubkey.deserialize Utils.decode_hex(public_key)

        r = sig.r
        r_bn = OpenSSL::BN.new(r, 16)

        s = sig.s
        s_bn = OpenSSL::BN.new(s, 16)

        group = OpenSSL::PKey::EC::Group.new('secp256k1')
        pubkey_bn = OpenSSL::BN.new(public_key, 16)
        pubkey_point = OpenSSL::PKey::EC::Point.new(group, pubkey_bn)
        
        q_point = pubkey_point.mul(r_bn, s_bn)

        h_bn = self.hash(q_point, pubkey_point, message) % N

        h_bn.eql?(r_bn)
      end


      # Hash (r | M).
      def self.hash(q_point, pubkey_point, message)
        sha256 = Digest::SHA256.new
        sha256 << q_point.to_octet_string(:compressed)
        sha256 << pubkey_point.to_octet_string(:compressed)
        sha256 << Utils.decode_hex(message)

        OpenSSL::BN.new(sha256.hexdigest, 16)
      end
    end

    class Signature
      attr_reader :r, :s
      def initialize(r, s)
        @r = r
        @s = s
      end

      def to_s
        "#{@r}#{@s}"
      end
    end
  end
end