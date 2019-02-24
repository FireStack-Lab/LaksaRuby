require 'Secp256k1'

module Laksa
  module Account
    class Transaction
      include Secp256k1

      attr_accessor :id, :version, :nonce, :amount, :gas_price, :gas_limit, :signature, :receipt, :sender_pub_key, :to_addr, :code, :data, :to_ds
      attr_accessor :provider, :status

      GET_TX_ATTEMPTS = 33

      def initialize(tx_params, provider, status = TxStatus::INITIALIZED, to_ds = false)
        if tx_params
          @version = tx_params.version;
          @nonce = tx_params.nonce
          @amount = tx_params.amount
          @gas_price = tx_params.gas_price
          @gas_limit = tx_params.gas_limit
          @signature = tx_params.signature
          @receipt = tx_params.receipt
          @sender_pub_key = tx_params.sender_pub_key
          @to_addr = tx_params.to_addr.downcase
          @code = tx_params.code || ''
          @data = tx_params.data || ''
        end

        @provider = provider
        @status = status
        @to_ds = to_ds
      end

      # constructs an already-confirmed transaction.
      def self.confirm(tx_params, provider)
        Transaction.new(tx_params, provider, TxStatus::CONFIRMED)
      end

      # constructs an already-rejected transaction.
      def self.reject(tx_params, provider) 
        Transaction.new(tx_params, provider, TxStatus::REJECTED)
      end

      def bytes
        protocol = Laksa::Proto::ProtoTransactionCoreInfo.new
        protocol.version = self.version
        protocol.nonce = self.nonce || 0
        protocol.toaddr =  Utils.decode_hex(self.to_addr.downcase)
        protocol.senderpubkey = Laksa::Proto::ByteArray.new(data: Utils.decode_hex(self.sender_pub_key))

        raise 'standard length exceeded for value' if self.amount.to_i > 2 ** 128 - 1

        protocol.amount = Laksa::Proto::ByteArray.new(data: bigint_to_bytes(self.amount.to_i))
        protocol.gasprice = Laksa::Proto::ByteArray.new(data: bigint_to_bytes(self.gas_price.to_i))
        protocol.gaslimit = self.gas_limit
        protocol.code = self.code
        protocol.data = self.data

        protocol.encode
      end

      def tx_params
        tx_params = TxParams.new

        tx_params.id = self.id
        tx_params.version = self.version
        tx_params.nonce = self.nonce
        tx_params.amount = self.amount
        tx_params.gas_price = self.gas_price
        tx_params.gas_limit = self.gas_limit
        tx_params.signature = self.signature
        tx_params.receipt = self.receipt
        tx_params.sender_pub_key = self.sender_pub_key
        tx_params.to_addr = self.to_addr ? Wallet.to_checksum_address(self.to_addr)[2..-1] : '0000000000000000000000000000000000000000'
        tx_params.code = self.code
        tx_params.data = self.data

        tx_params
      end

      def to_payload
        {
          version: self.version.to_i,
          nonce: self.nonce.to_i,
          to_addr: self.to_addr,
          amount: self.amount,
          pub_key: self.sender_pub_key,
          gas_price: self.gas_price,
          gas_limit: self.gas_limit,
          code: self.code,
          data: self.data,
          signature: self.signature
        }
      end

      def pending?
        @status == TxStatus::PENDING
      end

      def initialised?
        @status === TxStatus::INITIALIZED
      end

      def confirmed?
        @status === TxStatus::CONFIRMED;
      end 

      def rejected?
        @status === TxStatus::REJECTED;
      end

      # This sets the Transaction instance to a state
      # of pending. Calling this function kicks off a passive loop that polls the
      # lookup node for confirmation on the txHash.
      #
      # The polls are performed with a linear backoff:
      #
      # This is a low-level method that you should generally not have to use
      # directly.
      def confirm(tx_hash, max_attempts = GET_TX_ATTEMPTS, interval = 1)
        @status = TxStatus::PENDING
        1.upto(max_attempts) do 
          if self.track_tx(tx_hash)
            return self
          else
            sleep(interval)
          end
        end

        self.status = TxStatus::REJECTED
        throw 'The transaction is still not confirmed after ${maxAttempts} attempts.'
      end
      
      def track_tx(tx_hash) 
        puts "tracking transaction: #{tx_hash}"

        begin
          response = @provider.GetTransaction(tx_hash)
        rescue Exception => e
          puts "transaction not confirmed yet"
          puts e
        end

        if response['error']
          puts "transaction not confirmed yet"
          return false;
        end

        self.id = response['result']['ID']
        self.receipt = response['result']['receipt']
        self.receipt['cumulative_gas'] = response['result']['receipt']['cumulative_gas'].to_i

        if self.receipt && self.receipt['success']
          puts "Transaction confirmed!"
          self.status = TxStatus::CONFIRMED
        else
          puts "Transaction rejected!"
          self.status = TxStatus::REJECTED
        end

        true
      end

      private
      def bigint_to_bytes(value)
        raise 'standard length exceeded for value' if value > 2 ** 128 - 1
        bs = [value / (2 ** 64), value % (2 ** 64)].pack('Q>*')
      end
    end

    class TxParams
      attr_accessor :id, :version, :nonce, :amount, :gas_price, :gas_limit, :signature, :receipt, :sender_pub_key, :to_addr, :code, :data
      def initialize
      end
    end

    class TxStatus
      INITIALIZED = 0
      PENDING = 1
      CONFIRMED = 2
      REJECTED = 3
    end
  end
end