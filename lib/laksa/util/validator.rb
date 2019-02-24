module Laksa
  module Util
    class Validator
      def self.public_key?(public_key)
        m = /(0x)?\h{66}/ =~ public_key
        m != nil
      end

      def self.private_key?(private_key)
        m = /(0x)?\h{64}/ =~ private_key
        m != nil
      end

      def self.address?(address)
        m = /(0x)?\h{40}/ =~ address
        m != nil
      end

      def self.signature?(signature)
        m = /(0x)?\h{128}/ =~ signature
        m != nil
      end

      # checksum_address?
      #
      # takes hex-encoded string and returns boolean if address is checksumed
      #
      # @param {string} address
      # @returns {boolean}
      def self.checksum_address?(address)
        self.address?(address) && Laksa::Account::Wallet::to_checksum_address(address) == address
      end
    end
  end
end