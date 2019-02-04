  require "test_helper"

  class ProviderTest < Minitest::Test
    def setup
      @provider = Laksa::Jsonrpc::Provider.new('https://api.zilliqa.com/')
    end

    # Blockchain-related methods
    def test_get_network_id
      ret = @provider.GetNetworkId
      assert_equal "TestNet", ret
    end

    # def test_get_blockchain_info
    #   ret = @provider.GetBlockchainInfo
    #   assert ret != nil
    # end

    # def test_get_sharding_structure
    #   ret = @provider.GetShardingStructure
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('NumPeers')
    # end

    # def test_get_ds_block
    #   ret = @provider.GetDsBlock("1")
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('header')
    # end

    # def test_get_latest_ds_block
    #   ret = @provider.GetLatestDsBlock
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('header')
    # end

    # def test_get_num_ds_blocks
    #   ret = @provider.GetNumDSBlocks
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_ds_block_rate
    #   ret = @provider.GetDSBlockRate
    #   puts ret
    #   assert ret != nil
    # end

    # def test_ds_block_listing
    #   ret = @provider.DSBlockListing(1)
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('data')
    # end

    # def test_get_tx_block
    #   ret = @provider.GetTxBlock('40')
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('body')
    # end

    # def test_get_latest_tx_block
    #   ret = @provider.GetLatestTxBlock
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('body')
    # end

    # def test_get_num_tx_blocks
    #   ret = @provider.GetNumTxBlocks
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_tx_block_rate
    #   ret = @provider.GetTxBlockRate
    #   puts ret
    #   assert ret != nil
    # end

    # def test_tx_block_listing
    #   ret = @provider.TxBlockListing(1)
    #   puts ret
    #   assert ret != nil
    #   assert ret.has_key?('data')
    # end

    # def test_get_num_transactions
    #   ret = @provider.GetNumTransactions
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_transaction_rate
    #   ret = @provider.GetTransactionRate
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_current_mini_epoch
    #   ret = @provider.GetCurrentMiniEpoch
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_current_ds_epoch
    #   ret = @provider.GetCurrentDSEpoch
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_prev_difficulty
    #   ret = @provider.GetPrevDifficulty
    #   puts ret
    #   assert ret != nil
    # end

    # def test_get_prev_ds_difficulty
    #   ret = @provider.GetPrevDSDifficulty
    #   puts ret
    #   assert ret != nil
    # end

  # Transaction-related methods
  # TODO: to be implemented
  # def test_create_transaction
  #   datas = {
  #     "version": 65537,
  #     "nonce": 1,
  #     "toAddr": "0x4BAF5faDA8e5Db92C3d3242618c5B47133AE003C",
  #     "amount": "1000000000000",
  #     "pubKey": "0205273e54f262f8717a687250591dcfb5755b8ce4e3bd340c7abefd0de1276574",
  #     "gasPrice": "1000000000",
  #     "gasLimit": "1",
  #     "code": "",
  #     "data": "",
  #     "signature": "29ad673848dcd7f5168f205f7a9fcd1e8109408e6c4d7d03e4e869317b9067e636b216a32314dd37176c35d51f9d4c24e0e519ba80e66206457c83c9029a490d",
  #     "priority": false
  #   }
  #   ret = @provider.CreateTransaction
  #   puts ret
  #   assert ret != nil
  # end

  # def test_get_transaction
  #   transaction_id = "42752ebd7116bcb7d213ee065915055956e54b882a46e7ba0c343c94a52add07"
  #   ret = @provider.GetTransaction(transaction_id)
  #   puts ret
  #   assert ret != nil
  #   assert ret.has_key?('ID')
  #   assert_equal transaction_id, ret['ID']
  # end

  # def test_get_recent_transactions
  #   ret = @provider.GetRecentTransactions
  #   puts ret
  #   assert ret != nil
  #   assert ret.has_key?('TxnHashes')
  # end

  # def test_get_transactions_for_tx_block
  #   ret = @provider.GetTransactionsForTxBlock("2", 0)
  #   puts ret
  #   assert ret != nil
  # end

  # def test_get_num_txns_tx_epoch
  #   ret = @provider.GetNumTxnsTxEpoch
  #   puts ret
  #   assert ret != nil
  # end

  # def test_get_num_txns_ds_epoch
  #   ret = @provider.GetNumTxnsDSEpoch
  #   puts ret
  #   assert ret != nil
  # end

  # def test_get_minimum_gas_price
  #   ret = @provider.GetMinimumGasPrice
  #   puts ret
  #   assert ret != nil
  # end

  # # Contract-related methods
  # def test_get_smart_contract_code
  #   address = "8cb841ef4f1f61d44271e167557e160434bd6d63"
  #   ret = @provider.GetSmartContractCode(address)
  #   puts ret
  #   assert ret != nil
  #   assert ret.has_key?('code')
  # end

  # def test_get_smart_contract_init
  #   address = "8cb841ef4f1f61d44271e167557e160434bd6d63"
  #   ret = @provider.GetSmartContractInit(address)
  #   puts ret
  #   assert ret != nil
  # end

  # def test_get_smart_contract_state
  #   address = "8cb841ef4f1f61d44271e167557e160434bd6d63"
  #   ret = @provider.GetSmartContractState(address)
  #   puts ret
  #   assert ret != nil
  # end

  # def test_get_smart_contracts
  #   address = "8cb841ef4f1f61d44271e167557e160434bd6d63"
  #   ret = @provider.GetSmartContracts(address)
  #   puts ret
  #   assert ret != nil
  #   assert_equal address, ret['address']
  # end

  # def test_get_contract_address_from_transaction_id
  #   transaction_id = "42752ebd7116bcb7d213ee065915055956e54b882a46e7ba0c343c94a52add07"
  #   ret = @provider.GetContractAddressFromTransactionID(transaction_id)
  #   puts ret
  #   assert ret != nil
  # end

  # # Account-related methods
  # def test_get_balance
  #   user_address = '1eefc4f453539e5ee732b49eb4792b268c2f3908'
  #   ret = @provider.GetBalance(user_address)
  #   puts ret
  #   assert ret != nil
  #   assert ret.has_key?('balance')
  # end
end