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
      # @param {String} msg
      # @param {String} key
      def self.sign(message, private_key, public_key)
        sig = nil
        while !sig
          k = Util.encode_hex SecureRandom.random_bytes(32)
          k_bn = OpenSSL::BN.new(k, 16)

          sig = self.try_sign(message, private_key, k_bn, public_key)
        end

        sig
      end

      # trySign
      #
      # @param {String} message - the message to sign over
      # @param {String} privateKey - the private key
      # @param {BN} k_bn - output of the HMAC-DRBG
      #
      # @returns {Signature | null =>}
      def self.try_sign(message, private_key, k_bn, public_key)
        group = OpenSSL::PKey::EC::Group.new('secp256k1')

        prikey_bn = OpenSSL::BN.new(private_key, 16)

        pubkey_bn = OpenSSL::BN.new(public_key, 16)
        pubkey_point = OpenSSL::PKey::EC::Point.new(group, pubkey_bn)

        throw 'Bad private key.' if prikey_bn.zero? || prikey_bn >= N

        # 1a. check that k is not 0
        return nil if k_bn.zero? 

        # 1b. check that k is < the order of the group
        return nil if k_bn >= N

        # 2. Compute commitment Q = kG, where g is the base point
        q_point = pubkey_point.mul(0, k_bn)

        # 3. Compute the challenge r = H(Q || pubKey || msg)
        # mod reduce the r value by the order of secp256k1, n
        r_bn = hash(q_point, pubkey_point, message) % N

        return nil if r_bn.zero?

        # 4. Compute s = k - r * prv
        # 4a. Compute r * prv
        s_bn = r_bn * prikey_bn % N
        # 4b. Compute s = k - r * prv mod n
        s_bn = k_bn.mod_sub(s_bn, N)

        return nil if s_bn.zero?

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
        pubkey.deserialize Util.decode_hex(public_key)

        r = sig.r
        r_bn = OpenSSL::BN.new(r, 16)

        s = sig.s
        s_bn = OpenSSL::BN.new(s, 16)

        throw 'Invalid signature' if (s_bn.zero? || r_bn.zero?)

        throw 'Invalid signature' if (s_bn.negative? || r_bn.negative?)

        throw 'Invalid signature' if (s_bn >= N || r_bn >= N)

        group = OpenSSL::PKey::EC::Group.new('secp256k1')
        pubkey_bn = OpenSSL::BN.new(public_key, 16)
        pubkey_point = OpenSSL::PKey::EC::Point.new(group, pubkey_bn)

        throw 'Invalid public key' unless pubkey_point.on_curve?

        q_point = pubkey_point.mul(r_bn, s_bn)

        throw 'Invalid intermediate point.' if q_point.infinity?

        h_bn = self.hash(q_point, pubkey_point, message) % N

        throw 'Invalid hash.' if (h_bn.zero?)

        h_bn.eql?(r_bn)
      end


      # Hash (r | M).
      def self.hash(q_point, pubkey_point, message)
        sha256 = Digest::SHA256.new
        sha256 << q_point.to_octet_string(:compressed)
        sha256 << pubkey_point.to_octet_string(:compressed)
        sha256 << Util.decode_hex(message)

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