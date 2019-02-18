module Laksa
  module Account
    class Account
      attr_reader :private_key, :public_key, :address
      def initialize(private_key)
        @private_key = private_key
        @public_key = Laksa::Crypto::KeyTool.get_public_key_from_private_key(private_key, true)
        @address = Laksa::Crypto::KeyTool.get_address_from_public_key(@public_key)
      end

      # Takes a JSON-encoded keystore and passphrase, returning a fully
      # instantiated Account instance.
      def self.from_file(file, passphrase)
        key_store = Laksa::Crypto::KeyStore.new
        private_key = key_store.decrypt_private_key(file, passphrase)
        Account.new(private_key)
      end

      # Convert an Account instance to a JSON-encoded keystore.
      def to_file(passphrase, type)
        key_store = Laksa::Crypto::KeyStore.new
        json = key_store.encrypt_private_key(@private_key, passphrase, type);
      end

      # sign the passed in transaction with the account's private and public key
      def sign_transaction(tx)
        message = tx.bytes
        message_hex = Secp256k1::Utils.encode_hex(message)
        
        Laksa::Crypto::Schnorr.sign(message_hex, @private_key)
      end
    end
  end
end