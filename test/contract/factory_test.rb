require 'test_helper'

class FactoryTest < Minitest::Test
  def test_get_address_for_contract
    tx = Laksa::Account::Transaction.new(nil, nil)
    tx.sender_pub_key = '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a'
    tx.nonce = "19"

    address = Laksa::Contract::Factory.get_address_for_contract(tx);
    assert_equal '8f14cb1735b2b5fba397bea1c223d65d12b9a887', address
  end
end