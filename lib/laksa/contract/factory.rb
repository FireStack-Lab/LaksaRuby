require 'secp256k1'
require 'digest'

module Laksa
  module Contract
    class Factory
      include Secp256k1

      # Takes an array of Account objects and instantiates a Wallet instance.
      def initialize(provider, accounts)
        @provider = provider
        @accounts = accounts
        if accounts.length > 0
          @default_account = accounts[0] 
        else
          @default_account = nil
        end
      end

      # Creates a new keypair with a randomly-generated private key. The new
      # account is accessible by address.
      def create
        private_key = Laksa::Crypto::KeyTool.generate_private_key
        account = Laksa::Account::Account.new(private_key)

        @accounts[account.address] = account

        @default_account = account unless @default_account

        account.address
      end

      # Adds an account to the wallet by private key.
      def add_by_private_key(private_key)
        account = Laksa::Account::Account.new(private_key)

        @accounts[account.address] = account

        @default_account = account unless @default_account

        account.address
      end


      # Adds an account by keystore
      def add_by_keystore(keystore, passphrase)
        account = Laksa::Account::Account.from_file(keystore, passphrase)

        @accounts[account.address] = account

        @default_account = account unless @default_account

        account.address
      end

      # Removes an account from the wallet and returns boolean to indicate
      # failure or success.

      def remove(address)
        if @accounts.has_key?(address)
          @accounts.delete(address)

          true
        else
          false
        end
      end

      # Sets the default account of the wallet.
      def set_default(address) 
        @default_account = @accounts[address]
      end

      def self.to_checksum_address(address)
        address = address.downcase.gsub('0x', '')

        s1 = Digest::SHA256.hexdigest(Utils.decode_hex(address))
        v = s1.to_i(base=16)

        ret = ['0x']
        address.each_char.each_with_index do |c, idx|
          if '1234567890'.include?(c)
            ret << c 
          else
            ret << ((v & (2 ** (255 - 6 * idx))) < 1 ? c.downcase : c.upcase)
          end
        end

        ret.join
      end

      # signs an unsigned transaction with the default account.
      def sign(tx)
        tx_params = tx.tx_params
        if (tx_params.try(:sender_pub_key))
          # attempt to find the address
          address = Laksa::Crypto::KeyTool.get_address_from_public_key(tx_params.sender_pub_key)
          account = @accounts[address]
          raise 'Could not sign the transaction with address as it does not exist' unless account 

          self.sign_with(tx, address)
        else
          raise 'This wallet has no default account.' unless @default_account

          self.sign_with(tx, @default_account.address)  
        end
      end

      def sign_with(tx, address)
        account = @accounts[address]

        raise 'The selected account does not exist on this Wallet instance.' unless account 

        if tx.nonce == nil || tx.nonce.empty?
          result = @provider.GetBalance(account.address)
          tx.nonce = (result['nonce'] + 1).to_s
        end

        tx.sender_pub_key = account.public_key
        sig = account.sign_transaction(tx)
        tx.signature = sig.downcase
        tx
      end
    end
  end
end