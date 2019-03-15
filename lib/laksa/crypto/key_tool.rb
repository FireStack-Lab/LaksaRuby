require 'secp256k1'
require 'digest'

module Laksa
  module Crypto
    class KeyTool
      include Secp256k1
      def initialize(private_key)
        is_raw = private_key.length == 32 ? true : false

        @pk = PrivateKey.new(privkey: private_key, raw: is_raw)
      end

      def self.generate_private_key
        Util.encode_hex KeyTool.generate_random_bytes(32)
      end

      def self.generate_random_bytes(size)
        SecureRandom.random_bytes(size)
      end

      # getPubKeyFromPrivateKey
      #
      # takes a hex-encoded string (private key) and returns its corresponding
      # hex-encoded 33-byte public key.
      #
      # @param {string} privateKey
      # @returns {string}
      def self.get_public_key_from_private_key(private_key, is_compressed = true)
        is_raw = private_key.length == 32 ? true : false

        pk = PrivateKey.new(privkey: private_key, raw: is_raw)

        (Util.encode_hex pk.pubkey.serialize(compressed: is_compressed)).downcase
      end

      # getAddressFromPrivateKey
      #
      # takes a hex-encoded string (private key) and returns its corresponding
      # 20-byte hex-encoded address.
      #
      # @param {string} privateKey
      # @returns {string}
      def self.get_address_from_private_key(private_key)
        public_key = KeyTool.get_public_key_from_private_key(private_key)
        KeyTool.get_address_from_public_key(public_key)
      end

      # getAddressFromPublicKey
      # 
      # takes hex-encoded string and returns the corresponding address
      # 
      # @param {string} public_key
      # @returns {string}
      def self.get_address_from_public_key(public_key)
        orig_address = Digest::SHA256.hexdigest Util.decode_hex public_key
        orig_address[24..-1].downcase
      end
    end
  end
end