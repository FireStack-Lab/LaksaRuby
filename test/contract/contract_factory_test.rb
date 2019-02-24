require 'test_helper'

require_relative 'test_contract'
require_relative 'test_abi'

class ContractFactoryTest < Minitest::Test
  def setup
    @provider = Minitest::Mock.new
    @wallet = Laksa::Account::Wallet.new(@provider)
    @address = nil
    10.times do 
      ret = @wallet.create
      @address = ret unless @address
    end
  end

  def test_get_address_for_contract
    tx = Laksa::Account::Transaction.new(nil, nil)
    tx.sender_pub_key = '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a'
    tx.nonce = "19"

    address = Laksa::Contract::ContractFactory.get_address_for_contract(tx);
    assert_equal '8f14cb1735b2b5fba397bea1c223d65d12b9a887', address
  end

  def test_new_contracts_should_have_a_stauts_of_initialised
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'contractOwner',
        type: 'ByStr20',
        value: '0x124567890124567890124567890124567890',
      },
      { vname: 'name', type: 'String', value: 'NonFungibleToken' },
      { vname: 'symbol', type: 'String', value: 'NFT' },
    ], nil);

    assert contract.initialised?
    assert_equal Laksa::Contract::ContractStatus::INITIALISED, contract.status
  end

  def test_should_be_able_to_deploy_a_contract
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'contractOwner',
        type: 'ByStr20',
        value: '0x124567890124567890124567890124567890',
      },
      { vname: 'name', type: 'String', value: 'NonFungibleToken' },
      { vname: 'symbol', type: 'String', value: 'NFT' },
    ],
    ABI,
    )

    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
          Info: 'Non-contract txn, sent to shard',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: { success: true, cumulative_gas: '1000' },
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    @provider.expect("GetBalance", responses[0], [@address])
    @provider.expect("CreateTransaction", responses[1], [Hash])
    @provider.expect("GetTransaction", responses[2], ['some_hash'])

    deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000, 1000, nil)
    tx, deployed = contract.deploy(deploy_params)

    @provider.verify

    assert tx.confirmed?
    assert deployed.deployed?
    assert_equal Laksa::Contract::ContractStatus::DEPLOYED, deployed.status

    assert /[A-F0-9]+/ =~ contract.address
  end

  def test_should_not_swallow_network_errors
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'contractOwner',
        type: 'ByStr20',
        value: '0x124567890124567890124567890124567890',
      },
      { vname: 'name', type: 'String', value: 'NonFungibleToken' },
      { vname: 'symbol', type: 'String', value: 'NFT' },
    ],
    ABI,
    );

    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
          Info: 'Non-contract txn, sent to shard',
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    @provider.expect("GetBalance", responses[0], [@address])

    def @provider.CreateTransaction(payload)
      raise 'something bad happened'
    end

    deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000, 1000, nil)
    assert_raises 'something bad happened.' do 
      tx, deployed = contract.deploy(deploy_params)
    end

    @provider.verify
  end

  def test_if_the_underlying_transaction_is_rejected_contract_status_should_be_rejected
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'contractOwner',
        type: 'ByStr20',
        value: '0x124567890124567890124567890124567890',
      },
      { vname: 'name', type: 'String', value: 'NonFungibleToken' },
      { vname: 'symbol', type: 'String', value: 'NFT' },
    ],
    ABI,
    )

    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        error: {
          code: 444,
          message: 'Mega fail',
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    @provider.expect("GetBalance", responses[0], [@address])
    @provider.expect("CreateTransaction", responses[1], [Hash])

    deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000, 1000, nil)
    tx, contract = contract.deploy(deploy_params)

    @provider.verify

    assert tx.rejected?
    assert contract.rejected?
    assert_equal Laksa::Contract::ContractStatus::REJECTED, contract.status
  end

  def test_if_the_transaction_receipt_success_equal_false_contract_status_should_be_rejected
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'contractOwner',
        type: 'ByStr20',
        value: '0x124567890124567890124567890124567890',
      },
      { vname: 'name', type: 'String', value: 'NonFungibleToken' },
      { vname: 'symbol', type: 'String', value: 'NFT' },
    ],
    ABI,
    )

    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: {
            success: false,
            cumulative_gas: 1000,
          },
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    @provider.expect("GetBalance", responses[0], [@address])
    @provider.expect("CreateTransaction", responses[1], [Hash])
    @provider.expect("GetTransaction", responses[2], ['some_hash'])

    deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000, 1000, nil)
    tx, contract = contract.deploy(deploy_params)

    @provider.verify

    assert tx.rejected?
    assert contract.rejected?

  end

  def test_should_be_able_to_call_a_transition
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'contractOwner',
        type: 'ByStr20',
        value: '0x124567890124567890124567890124567890',
      },
      { vname: 'name', type: 'String', value: 'NonFungibleToken' },
      { vname: 'symbol', type: 'String', value: 'NFT' },
    ],
    ABI,
    )

    responses = [
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 1,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: {
            success: true,
            cumulative_gas: 1000,
          },
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          balance: 888,
          nonce: 2,
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          TranID: 'some_hash',
        },
      },
      {
        id: 1,
        jsonrpc: '2.0',
        result: {
          ID: 'some_hash',
          receipt: {
            success: true,
            cumulative_gas: 1000,
          },
        },
      },
    ].map do |res|
      JSON.parse(JSON.generate(res))
    end

    @provider.expect("GetBalance", responses[0], [@address])
    @provider.expect("CreateTransaction", responses[1], [Hash])
    @provider.expect("GetTransaction", responses[2], ['some_hash'])
    @provider.expect("GetBalance", responses[3], [@address])
    @provider.expect("CreateTransaction", responses[4], [Hash])
    @provider.expect("GetTransaction", responses[5], ['some_hash'])

    deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000, 1000, nil)
    tx, contract = contract.deploy(deploy_params)

    call_tx = contract.call(
      'myTransition',
      [
        { vname: 'param_1', type: 'String', value: 'hello' },
        { vname: 'param_2', type: 'String', value: 'world' },
      ],
      {
        version: Laksa::Util.pack(8, 8),
        amount: 0,
        gasPrice: 1000,
        gasLimit: 1000
      }
      )

    @provider.verify

    receipt = call_tx.tx_params.receipt

    assert receipt && receipt['success']
  end
end