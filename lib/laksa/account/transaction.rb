require 'Secp256k1'
require 'protobuf'

module Laksa
  module Account
    class Transaction
      include Secp256k1

      def initialize
      end

      def encode_transaction_proto(tx_params)
        protocol = Laksa::Proto::ProtoTransactionCoreInfo.new
        protocol.version = tx_params.version
        protocol.nonce = tx_params.nonce || 0
        protocol.toaddr =  Utils.decode_hex(tx_params.to_addr.downcase)
        protocol.senderpubkey = Laksa::Proto::ByteArray.new(data: Utils.decode_hex(tx_params.sender_pub_key))

        raise 'standard length exceeded for value' if tx_params.amount.to_i > 2 ** 128 - 1

        value = tx_params.amount.to_i
        bs = [value / (2 ** 64), value % (2 ** 64)].pack('Q>*')

        protocol.amount = Laksa::Proto::ByteArray.new(data: bigint_to_bytes(tx_params.amount.to_i))
        protocol.gasprice = Laksa::Proto::ByteArray.new(data: bigint_to_bytes(tx_params.gas_price.to_i))
        protocol.gaslimit = tx_params.gas_limit
        protocol.code = tx_params.code
        protocol.data = tx_params.data

        protocol.encode
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
  end
end