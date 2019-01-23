require "test_helper"
require 'secp256k1'

class TransactionTest < Minitest::Test
  def test_encode_transaction_proto
    tx_params = Laksa::Account::TxParams.new
    tx_params.version = '0'
    tx_params.nonce = '0'
    tx_params.to_addr = '2E3C9B415B19AE4035503A06192A0FAD76E04243'
    tx_params.sender_pub_key = '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a'
    tx_params.amount = '340282366920938463463374607431768211455'
    tx_params.gas_price = '100'
    tx_params.gas_limit = '1000'
    tx_params.code = 'abc'
    tx_params.data = 'def'

    transaction = Laksa::Account::Transaction.new

    ret = transaction.encode_transaction_proto(tx_params)
    ret_hex = Secp256k1::Utils.encode_hex(ret)
    exp = '080010001A142E3C9B415B19AE4035503A06192A0FAD76E0424322230A210246E7178DC8253201101E18FD6F6EB9972451D121FC57AA2A06DD5C111E58DC6A2A120A10FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF32120A100000000000000000000000000000006438E80742036162634A03646566'
    assert_equal exp.downcase, ret_hex
  end

  def test_encode_transaction_proto_for_null_code_and_null_data
    tx_params = Laksa::Account::TxParams.new
    tx_params.version = '0'
    tx_params.nonce = '0'
    tx_params.to_addr = '2E3C9B415B19AE4035503A06192A0FAD76E04243'
    tx_params.sender_pub_key = '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a'
    tx_params.amount = '10000'
    tx_params.gas_price = '100'
    tx_params.gas_limit = '1000'
    
    transaction = Laksa::Account::Transaction.new

    ret = transaction.encode_transaction_proto(tx_params)
    ret_hex = Secp256k1::Utils.encode_hex(ret)
    exp = '080010001A142E3C9B415B19AE4035503A06192A0FAD76E0424322230A210246E7178DC8253201101E18FD6F6EB9972451D121FC57AA2A06DD5C111E58DC6A2A120A100000000000000000000000000000271032120A100000000000000000000000000000006438E807'
    assert_equal exp.downcase, ret_hex
  end
end