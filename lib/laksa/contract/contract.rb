require 'json'

module Laksa
  module Contract
    class Contract
      include Account

      NIL_ADDRESS = "0000000000000000000000000000000000000000";

      def initialize(factory, code, abi, address, init, states)
        @factory = factory
        @code = code
        @abi = abi
        @address = address
        @init = init
        @states = states

        @provider = factory.provider
      end

      def deploy(deploy_params, attempts, interval) 
        raise 'Cannot deploy without code or initialisation parameters.' if @code == nil || @code == ''
        raise 'Cannot deploy without code or initialisation parameters.' if @init == nil || @init.length == 0

        tx_params = TxParams.new
        tx_params.id = deploy_params.id
        tx_params.version = deploy_params.version
        tx_params.nonce = deploy_params.nonce
        tx_params.to_addr = NIL_ADDRESS
        tx_params.sender_pub_key = gas_limit.sender_pub_key
        tx_params.amount = '0'
        tx_params.gas_price = deploy_params.gas_price
        tx_params.gas_limit = deploy_params.gas_limit
        tx_params.code = @code.gsub("/\\", "")
        tx_params.data = @init.to_json.gsub('\\"', '"')

        tx = Transaction.new(tx_params, @provider)

        tx = this.prepare_tx(transaction, attempts, interval);

        if tx.rejected?
          @status = ContractStatus::REJECTED
          
          return [tx, self]
        end

        @status = ContractStatus::DEPLOYED
        @address = ContractFactory.get_address_for_contract(tx)

        [tx, self]
      end

      def prepare_tx(tx, attempts, interval)
        tx = @signer.sign(tx);

        begin
          result = @provider.CreateTransaction(tx.to_payload())
          tx.confirm(result['TranID'], attempts, interval)  
        rescue Exception => e
          tx.status = TxStatus::REJECTED
        end
        
        tx
      end
    end

    class ContractStatus
      DEPLOYED = 0
      REJECTED = 1
      INITIALISED = 2
    end

    class Value
      attr_reader :vname, :type, :value
      def initialize(vname, type, value)
        @vname = vname
        @type = type
        @value = value
      end
    end

    class DeployParams 
      attr_reader :id, :version, :nonce, :gas_price, :gas_limit, :sender_pub_key
      def initialize(id, version, nonce, gas_price, gas_limit, sender_pub_key)
        @id = id
        @version = version
        @nonce = nonce
        @gas_price = gas_price
        @gas_limit = gas_limit
        @sender_pub_key = sender_pub_key
      end
    end
  end
end