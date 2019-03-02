require 'jsonrpc-client'

module JSONRPC
  class Base
    def self.make_id
      "1"
    end
  end
end

module Laksa
  module Jsonrpc
    class Provider
      def initialize(endpoint)
        @client = JSONRPC::Client.new(endpoint)
      end

      def method_missing(sym, *args)
        @client.invoke(sym.to_s, args)
      end
    end
  end
end