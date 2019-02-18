require "test_helper"

class TransactionFactoryTest < Minitest::Test
  def test_create_a_fresh_tx
    provider = Laksa::Jsonrpc::Provider.new('https://mock.zilliqa.com')
    wallet = Laksa::Account::Wallet.new(provider)
    transaction_factory = Laksa::Account::TransactionFactory.new(provider, wallet)

    tx_params = Laksa::Account::TxParams.new
    tx_params.version = '0'
    tx_params.amount = '0'
    tx_params.gas_price = '1'
    tx_params.gas_limit = '100'
    tx_params.to_addr = '0x88888888888888888888'

    tx = transaction_factory.new(tx_params)

    assert tx.initialised?
end
end