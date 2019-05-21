require 'bitcoin'

module Laksa
  module Util
    class Bech32

      def self.to_bech32(address)
        raise 'Invalid address format.' unless Validator.address?(address)

        address = address.sub('0x','')

        ret = Bitcoin::Bech32.convert_bits(Util.decode_hex(address).bytes, from_bits: 8, to_bits: 5, pad: false)

        Bitcoin::Bech32.encode('zil', ret);
      end

      def self.from_bech32(address)
        data = Bitcoin::Bech32.decode(address)

        raise 'Expected hrp to be zil' unless data[0] == 'zil'

        ret = Bitcoin::Bech32.convert_bits(data[1], from_bits: 5, to_bits: 8, pad: false)

        Laksa::Account::Wallet.to_checksum_address(Util.encode_hex(ret.pack('c*'))).sub('0x', '')
      end
    end
  end
end