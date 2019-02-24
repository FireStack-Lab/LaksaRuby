require 'json'

module Laksa
  module Contract
    class Contract
      include Account

      NIL_ADDRESS = "0000000000000000000000000000000000000000";

      attr_reader :factory, :provider, :signer, :code, :abi, :init, :state, :address, :status

      def initialize(factory, code, abi, address, init, state)
        @factory = factory
        @provider = factory.provider
        @signer = factory.signer

        @code = code
        @abi = abi
        @init = init
        @state = state

        if address && !address.empty?
          @address = address
          @status = ContractStatus::DEPLOYED
        else
          @status = ContractStatus::INITIALISED
        end
      end

      def initialised?
        return @status === ContractStatus::INITIALISED
      end

      def deployed?
        return @status === ContractStatus::DEPLOYED
      end

      def rejected?
        return @status === ContractStatus::REJECTED
      end

      def deploy(deploy_params, attempts = 33, interval = 1000, to_ds = false) 
        raise 'Cannot deploy without code or initialisation parameters.' if @code == nil || @code == ''
        raise 'Cannot deploy without code or initialisation parameters.' if @init == nil || @init.length == 0

        tx_params = TxParams.new
        tx_params.id = deploy_params.id
        tx_params.version = deploy_params.version
        tx_params.nonce = deploy_params.nonce
        tx_params.sender_pub_key = deploy_params.sender_pub_key
        tx_params.gas_price = deploy_params.gas_price
        tx_params.gas_limit = deploy_params.gas_limit

        tx_params.to_addr = NIL_ADDRESS
        tx_params.amount = '0'
        tx_params.code = @code.gsub("/\\", "")
        tx_params.data = @init.to_json.gsub('\\"', '"')

        tx = Transaction.new(tx_params, @provider)

        tx = self.prepare_tx(tx, attempts, interval);

        if tx.rejected?
          @status = ContractStatus::REJECTED
          
          return [tx, self]
        end

        @status = ContractStatus::DEPLOYED
        @address = ContractFactory.get_address_for_contract(tx)

        [tx, self]
      end

      def call(transition, args, params, attempts = 33, interval = 1000, to_ds = false)
        data = {
          _tag: transition,
          params: args,
        };

        return 'Contract has not been deployed!' unless @address

        tx_params = TxParams.new
        tx_params.id = params['id'] if params.has_key?('id')
        tx_params.version = params['version'] if params.has_key?('version') 
        tx_params.nonce = params['nonce'] if params.has_key?('nonce') 
        tx_params.sender_pub_key = params['sender_pub_key'] if params.has_key?('sender_pub_key') 
        tx_params.gas_price = params['gas_price'] if params.has_key?('gas_price') 
        tx_params.gas_limit = params['gas_limit'] if params.has_key?('gas_limit') 

        tx_params.to_addr = @address
        tx_params.data = JSON.generate(data)

        tx = Transaction.new(tx_params, @provider, TxStatus::INITIALIZED, to_ds)

        tx = self.prepare_tx(tx, attempts, interval)
      end

      def state
        return [] unless self.deployed

        response = @provider.GetSmartContractState(@address)
        return response.result
      end

      def prepare_tx(tx, attempts, interval)
        tx = @signer.sign(tx);

        response = @provider.CreateTransaction(tx.to_payload)

        if response['error']
          tx.status = TxStatus::REJECTED
        else
          tx.confirm(response['result']['TranID'], attempts, interval)
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