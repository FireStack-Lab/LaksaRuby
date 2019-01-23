require 'secp256k1'
require 'digest'

module Laksa
  module Account
    class Wallet
      include Secp256k1

      def initialize
      end

      def self.to_checksum_address(address)
        address = address.downcase.gsub('0x', '')

        s1 = Digest::SHA256.hexdigest(Utils.decode_hex(address))
        v = s1.to_i(base=16)
        
        ret = ['0x']
        address.each_char.each_with_index do |c, idx|
          if '1234567890'.include?(c)
            ret << c 
          else
            ret << ((v & (2 ** (255 - 6 * idx))) < 1 ? c.downcase : c.upcase)
          end
        end

        ret.join
      end

      def self.is_public_key(public_key)
        /\h{66}/ =~ public_key
      end
    end
  end
end