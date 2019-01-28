require 'test_helper'

class WalletTest < Minitest::Test
  def test_to_checksum_address
    assert_equal Laksa::Account::Wallet.to_checksum_address('4BAF5FADA8E5DB92C3D3242618C5B47133AE003C'), '0x4BAF5faDA8e5Db92C3d3242618c5B47133AE003C'
    assert_equal Laksa::Account::Wallet.to_checksum_address('448261915A80CDE9BDE7C7A791685200D3A0BF4E'), '0x448261915a80cdE9BDE7C7a791685200D3A0bf4E'
    assert_equal Laksa::Account::Wallet.to_checksum_address('DED02FD979FC2E55C0243BD2F52DF022C40ADA1E'), '0xDed02fD979fC2e55c0243bd2F52df022c40ADa1E'
    assert_equal Laksa::Account::Wallet.to_checksum_address('13F06E60297BEA6A3C402F6F64C416A6B31E586E'), '0x13F06E60297bea6A3c402F6f64c416A6b31e586e'
    assert_equal Laksa::Account::Wallet.to_checksum_address('1A90C25307C3CC71958A83FA213A2362D859CF33'), '0x1a90C25307C3Cc71958A83fa213A2362D859CF33'
    assert_equal Laksa::Account::Wallet.to_checksum_address('625ABAEBD87DAE9AB128F3B3AE99688813D9C5DF'), '0x625ABAebd87daE9ab128f3B3AE99688813d9C5dF'
    assert_equal Laksa::Account::Wallet.to_checksum_address('36BA34097F861191C48C839C9B1A8B5912F583CF'), '0x36Ba34097f861191C48C839c9b1a8B5912f583cF'
    assert_equal Laksa::Account::Wallet.to_checksum_address('D2453AE76C9A86AAE544FCA699DBDC5C576AEF3A'), '0xD2453Ae76C9A86AAe544fca699DbDC5c576aEf3A'
    assert_equal Laksa::Account::Wallet.to_checksum_address('72220E84947C36118CDBC580454DFAA3B918CD97'), '0x72220e84947c36118cDbC580454DFaa3b918cD97'
    assert_equal Laksa::Account::Wallet.to_checksum_address('50F92304C892D94A385CA6CE6CD6950CE9A36839'), '0x50f92304c892D94A385cA6cE6CD6950ce9A36839'
  end

  def test_create
    wallet = Laksa::Account::Wallet.new(nil, {})
    address = wallet.create
    assert address
    assert Laksa::Util::Validator.address?(address)
  end

  def test_add_by_private_key
    wallet = Laksa::Account::Wallet.new(nil, {})
    address = wallet.add_by_private_key('24180e6b0c3021aedb8f5a86f75276ee6fc7ff46e67e98e716728326102e91c9')
    assert address
    assert Laksa::Util::Validator.address?(address)
  end

  def test_add_by_key_store
    json = "{\"address\":\"B5C2CDD79C37209C3CB59E04B7C4062A8F5D5271\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"cipherparams\":{\"iv\":\"BB77D985DFF840E54EE52510DDF6FE38\"},\"ciphertext\":\"2064375F0A006F70381B180B4B25A139F18F19A40F24ACA9B30AC9E51488DFD4\",\"kdf\":\"pbkdf2\",\"kdfparams\":{\"n\":8192,\"c\":262144,\"r\":8,\"p\":1,\"dklen\":32,\"salt\":[119,19,15,64,53,-57,27,-111,36,105,-72,36,-59,5,-128,77,41,113,-78,-60,66,-102,-123,1,100,-45,-114,80,71,-16,-75,31]},\"mac\":\"8F00ED9E2C84C9387CBC70AE305DBE7B87F87CE106227C381E5EA928A265BB8F\"},\"id\":\"9b5e1a6d-54e1-43a2-8a10-49ab4e41b903\",\"version\":3}\n";
    wallet = Laksa::Account::Wallet.new(nil, {})
    address = wallet.add_by_keystore(json, "xiaohuo")
    assert address
    assert Laksa::Util::Validator.address?(address)
  end

  def test_sign
    private_key = "e19d05c5452598e24caad4a0d85a49146f7be089515c905ae6a19e8a578a6930"
    public_key = '0246e7178dc8253201101e18fd6f6eb9972451d121fc57aa2a06dd5c111e58dc6a'

    wallet = Laksa::Account::Wallet.new(nil, {})
    wallet.add_by_private_key(private_key)

    tx_params = Laksa::Account::TxParams.new
    tx_params.version = '0'
    tx_params.nonce = '0'
    tx_params.to_addr = '2E3C9B415B19AE4035503A06192A0FAD76E04243'
    tx_params.sender_pub_key = public_key
    tx_params.amount = '340282366920938463463374607431768211455'
    tx_params.gas_price = '100'
    tx_params.gas_limit = '1000'
    tx_params.code = 'abc'
    tx_params.data = 'def'

    tx = Laksa::Account::Transaction.new(tx_params, nil)

    exp = '3045022100ab6ee570de8b55c4e1c5c34379e1f563e8eaee89ebd3af324f2aae3323a74b1202207cbe35a6dd450ba26a8980c78c444820192f775d9017cafd81082eb2b64a7a73'
    
    wallet.sign(tx)
    assert_equal exp, tx.signature

    message = tx.bytes
    message_hex = Secp256k1::Utils.encode_hex(message)
    result = Laksa::Crypto::Schnorr.verify('111', tx.signature, public_key)
    assert result
  end
end