require "test_helper"
require 'secp256k1'

class TransactionTest < Minitest::Test
    def test_create
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

        tx = Laksa::Account::Transaction.new(tx_params, nil)

        ret_tx_params = tx.tx_params
        assert_nil ret_tx_params.id
        assert_equal tx_params.version, ret_tx_params.version
        assert_equal tx_params.nonce, ret_tx_params.nonce
        assert_equal tx_params.to_addr.downcase, ret_tx_params.to_addr
        assert_equal tx_params.sender_pub_key, ret_tx_params.sender_pub_key
        assert_equal tx_params.amount, ret_tx_params.amount
        assert_equal tx_params.gas_price, ret_tx_params.gas_price
        assert_equal tx_params.gas_limit, ret_tx_params.gas_limit
        assert_equal tx_params.code, ret_tx_params.code
        assert_equal tx_params.data, ret_tx_params.data
    end

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

        tx = Laksa::Account::Transaction.new(tx_params, nil)

        ret = tx.bytes
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

        tx = Laksa::Account::Transaction.new(tx_params, nil)

        ret = tx.bytes
        ret_hex = Secp256k1::Utils.encode_hex(ret)
        exp = '080010001a142e3c9b415b19ae4035503a06192a0fad76e0424322230a210246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a2a120a100000000000000000000000000000271032120a100000000000000000000000000000006438e80742004a00'
        assert_equal exp.downcase, ret_hex
    end
end