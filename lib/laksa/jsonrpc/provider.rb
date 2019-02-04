# require 'jimson'

# module Jimson
#   class ClientHelper
#     def self.make_id
#       "1"
#     end
#   end
# end

# module Laksa
#   module Jsonrpc
#     class Provider
#       def initialize(endpoint)
#         @client = Jimson::Client.new(endpoint)
#       end

#       def method_missing(sym, *args)
#         @client[sym.to_s, *args]
#       end
#     end
#   end
# end

require 'jsonrpc-client'

module Laksa
  module Jsonrpc
    class Provider
      def initialize(endpoint)
        @client = JSONRPC::Client.new(endpoint)
      end

      def method_missing(sym, *args)
        @client.send(sym.to_s, *args)
      end
    end
  end
end