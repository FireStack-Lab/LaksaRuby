require 'test_helper'

require_relative 'test_contract'
require_relative 'test_abi'

class ContractTest < Minitest::Test
  include Laksa

  def test_deploy
    @provider = Laksa::Jsonrpc::Provider.new('https://dev-api.zilliqa.com')
    @wallet = Laksa::Account::Wallet.new(@provider)
    
    factory = Laksa::Contract::ContractFactory.new(@provider, @wallet)
    contract = factory.new_contract(TEST_CONTRACT, [
      {
        vname: 'owner',
        type: 'ByStr20',
        value: `0x${process.env.GENESIS_ADDRESS}`,
      },
      {
        vname: '_scilla_version',
        type: 'Uint32',
        value: '0',
      },
    ]
    )

    deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000000000, 5000, nil)
    tx, contract = contract.deploy(deploy_params, 38, 1000)

    address = contract.address

    assert tx.confirmed?
    assert deployed.deployed?
  end
end