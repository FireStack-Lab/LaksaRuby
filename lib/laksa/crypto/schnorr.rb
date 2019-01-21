require 'secp256k1'
require 'digest'

module Laksa
  module Crypto
    class Schnorr
      include Secp256k1

      def initialize()
      end

      def self.sign(message, private_key)
        is_raw = private_key.length == 32 ? true : false
        pk = PrivateKey.new(privkey: private_key, raw: is_raw)
        msg = Utils.decode_hex(message)
        sig = Utils.encode_hex(pk.ecdsa_serialize(pk.ecdsa_sign(msg, raw: msg.size == 32)))
      end

      def self.verify(message, sig, public_key)
        pubkey = PublicKey.new(pubkey: public_key)
        pubkey.ecdsa_verify(message, sig)
      end
    end
  end
end