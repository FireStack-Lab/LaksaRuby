# encoding: utf-8

##
# This file is auto-generated. DO NOT EDIT!
#
require 'protobuf'

module Laksa
  module Proto
    ::Protobuf::Optionable.inject(self) { ::Google::Protobuf::FileOptions }

    ##
    # Message Classes
    #
    class ByteArray < ::Protobuf::Message; end
    class ProtoTransactionCoreInfo < ::Protobuf::Message; end
    class ProtoTransaction < ::Protobuf::Message; end
    class ProtoTransactionReceipt < ::Protobuf::Message; end
    class ProtoTransactionWithReceipt < ::Protobuf::Message; end


    ##
    # Message Fields
    #
    class ByteArray
      required :bytes, :data, 1
    end

    class ProtoTransactionCoreInfo
      optional :uint32, :version, 1
      optional :uint64, :nonce, 2
      optional :bytes, :toaddr, 3
      optional ::Laksa::Proto::ByteArray, :senderpubkey, 4
      optional ::Laksa::Proto::ByteArray, :amount, 5
      optional ::Laksa::Proto::ByteArray, :gasprice, 6
      optional :uint64, :gaslimit, 7
      optional :bytes, :code, 8
      optional :bytes, :data, 9
    end

    class ProtoTransaction
      optional :bytes, :tranid, 1
      optional ::Laksa::Proto::ProtoTransactionCoreInfo, :info, 2
      optional ::Laksa::Proto::ByteArray, :signature, 3
    end

    class ProtoTransactionReceipt
      optional :bytes, :receipt, 1
      optional :uint64, :cumgas, 2
    end

    class ProtoTransactionWithReceipt
      optional ::Laksa::Proto::ProtoTransaction, :transaction, 1
      optional ::Laksa::Proto::ProtoTransactionReceipt, :receipt, 2
    end

  end

end

