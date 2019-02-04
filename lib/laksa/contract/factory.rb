require 'secp256k1'
require 'digest'

module Laksa
  module Contract
    class Factory
      include Secp256k1

      attr_reader :provider, :signer

      def initialize(provider, signer)
        @provider = provider
        @signer = signer
      end

      def self.get_address_for_contract(tx)
        sha256 = Digest::SHA256.new

        sender_address = Laksa::Crypto::KeyTool.get_address_from_public_key(tx.sender_pub_key)

        sha256 << Utils.decode_hex(sender_address)

        nonce = 0;
        if tx.nonce && !tx.nonce.empty?
          nonce = tx.nonce.to_i - 1
        end
        
        nonce_hex = [nonce].pack('Q>*')

        sha256 << nonce_hex

        sha256.hexdigest[24..-1]
      end

      def new_contract(code, init, abi) 
        Contract.new(self, code, abi, nil, init, nil)
      end

      def at_contract(address, code, init, abi)
        Contract.new(self, code, abi, address, init, nil)
      end
    end
  end
end