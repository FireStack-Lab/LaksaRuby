require 'Secp256k1'
require 'protobuf'

module Laksa
  module Account
    class Transaction
      include Secp256k1

      attr_accessor :id, :version, :nonce, :amount, :gas_price, :gas_limit, :signature, :receipt, :sender_pub_key, :to_addr, :code, :data
      attr_accessor :provider, :status

      GET_TX_ATTEMPTS = 33

      def initialize(tx_params, provider, status = TxStatus::INITIALIZED)
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

        @provider = provider
        @status = status
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
        tx_params.sender_pub_key = self.sender_pub_key.downcase
        tx_params.to_addr = self.to_addr ? self.to_addr.downcase : '0000000000000000000000000000000000000000'
        tx_params.code = self.code
        tx_params.data = self.data

        tx_params
      end

      def pending?
        self.status == TxStatus::PENDING
      end

      def initialised?
        self.status === TxStatus::INITIALIZED
      end

      def confirmed?
        this.status === TxStatus::CONFIRMED;
      end 

      def rejected
        this.status === TxStatus::REJECTED;
      end


      # Similar to the Promise API. This sets the Transaction instance to a state
      # of pending. Calling this function kicks off a passive loop that polls the
      # lookup node for confirmation on the txHash.
      #
      # The polls are performed with a linear backoff:
      #
      # This is a low-level method that you should generally not have to use
      # directly.
      def confirm(tx_hash, max_attempts = GET_TX_ATTEMPTS, interval = 1)
        this.status = TxStatus::Pending;
        1.upto(max_attempts) do 
          if self.track_tx(tx_hash)
            return self
          else
            sleep(interval)
          end
        end

        self.status = TxStatus::REJECTED
      end
      
      def track_tx(tx_hash) 
        puts "tracking transaction: #{tx_hash}"

        begin
          response = this.provider.GetTransaction(tx_hash)
        rescue Exception => e
          puts "transaction not confirmed yet"
          puts e
        end

        unless response
          puts "transaction not confirmed yet"
          return false;
        end

        self.id = response['ID']
        self.receipt = response['receipt']
        
        if response['receipt'] && response['receipt']['success']
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

    class TxReceipt
      attr_accessor :success, :cumulative_gas
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