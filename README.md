# Laksa

Laksa -- Zilliqa Blockchain Ruby Library

The project is still under development.

## Requirement

Ruby(2.5.3)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'laksa'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install laksa

## Usage

### Generate A new address
```ruby
private_key = Laksa::Crypto::KeyTool.generate_private_key
public_key = Laksa::Crypto::KeyTool.get_public_key_from_private_key(private_key)
address = Laksa::Crypto::KeyTool.get_address_from_private_key(private_key)
```

### Validate an address
```ruby
address = '2624B9EA4B1CD740630F6BF2FEA82AAC0067070B'
Laksa::Util::Validator.address?(address)
```

### Validate checksum address
```ruby
checksum_address = '0x4BAF5faDA8e5Db92C3d3242618c5B47133AE003C'
Laksa::Util::Validator.checksum_address?(checksum_address)
```

### Deploy and Call a transaction
```ruby
private_key = "e19d05c5452598e24caad4a0d85a49146f7be089515c905ae6a19e8a578a6930"

provider = Laksa::Jsonrpc::Provider.new('https://dev-api.zilliqa.com')
wallet = Laksa::Account::Wallet.new(provider)
address = wallet.add_by_private_key(private_key)

factory = Laksa::Contract::ContractFactory.new(provider, wallet)

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

deploy_params = Laksa::Contract::DeployParams.new(nil, Laksa::Util.pack(8, 8), nil, 1000, 1000, nil)
tx, deployed = contract.deploy(deploy_params)    

assert tx.confirmed?
assert deployed.deployed?
assert_equal Laksa::Contract::ContractStatus::DEPLOYED, deployed.status

assert /[A-F0-9]+/ =~ contract.address

# call a deployed contract
call_tx = deployed.call(
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
      })


receipt = call_tx.tx_params.receipt
```

the definition of [TEST_CONTRACT](https://github.com/FireStack-Lab/LaksaRuby/blob/master/test/contract/test_contract.rb) and [ABI](https://github.com/FireStack-Lab/LaksaRuby/blob/master/test/contract/test_abi.rb) can be found in this folder. 