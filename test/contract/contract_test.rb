require 'test_helper'

class ContractTest < Minitest::Test
  include Laksa

  def test_deploy
    code = "scilla_version 0\n" +
    "\n" +
    "    (* HelloWorld contract *)\n" +
    "\n" +
    "    import ListUtils\n" +
    "\n" +
    "    (***************************************************)\n" +
    "    (*               Associated library                *)\n" +
    "    (***************************************************)\n" +
    "    library HelloWorld\n" +
    "\n" +
    "    let one_msg =\n" +
    "      fun (msg : Message) =>\n" +
    "      let nil_msg = Nil {Message} in\n" +
    "      Cons {Message} msg nil_msg\n" +
    "\n" +
    "    let not_owner_code = Int32 1\n" +
    "    let set_hello_code = Int32 2\n" +
    "\n" +
    "    (***************************************************)\n" +
    "    (*             The contract definition             *)\n" +
    "    (***************************************************)\n" +
    "\n" +
    "    contract HelloWorld\n" +
    "    (owner: ByStr20)\n" +
    "\n" +
    "    field welcome_msg : String = \"\"\n" +
    "\n" +
    "    transition setHello (msg : String)\n" +
    "      is_owner = builtin eq owner _sender;\n" +
    "      match is_owner with\n" +
    "      | False =>\n" +
    "        msg = {_tag : \"Main\"; _recipient : _sender; _amount : Uint128 0; code : not_owner_code};\n" +
    "        msgs = one_msg msg;\n" +
    "        send msgs\n" +
    "      | True =>\n" +
    "        welcome_msg := msg;\n" +
    "        msg = {_tag : \"Main\"; _recipient : _sender; _amount : Uint128 0; code : set_hello_code};\n" +
    "        msgs = one_msg msg;\n" +
    "        send msgs\n" +
    "      end\n" +
    "    end\n" +
    "\n" +
    "\n" +
    "    transition getHello ()\n" +
    "        r <- welcome_msg;\n" +
    "        e = {_eventname: \"getHello()\"; msg: r};\n" +
    "        event e\n" +
    "    end";

    init = [Contract::Value.new('_scilla_version', 'Uint32', '0'), Contract::Value.new('owner', 'ByStr20', '0x9bfec715a6bd658fcb62b0f8cc9bfa2ade71434a')]
    
    wallet = Account::Wallet.new
    wallet.add_by_private_key('e19d05c5452598e24caad4a0d85a49146f7be089515c905ae6a19e8a578a6930')
    
    factory = Contract::Factory.new(Jsonrpc::Provider.new('https://dev-api.zilliqa.com'), wallet)

    contract = factory.new_contract(code, init, '')
    
    deploy_params = Contract::DeployParams.new(nil, Util.pack(2, 8), nil, '1000000000', '10000', '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a')
    tx, contract = contract.deploy(deployParams, 300, 3);

    # System.out.println("result is: " + result.toString());

    # String transactionFee = new BigInteger(result.getKey().getReceipt().getCumulative_gas()).multiply(new BigInteger(result.getKey().getGasPrice())).toString();
    # System.out.println("transaction fee is: " + transactionFee);
  end
end