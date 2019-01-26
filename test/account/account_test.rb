require 'test_helper'

class AccountTest < Minitest::Test
  def test_create_account
    private_key = "24180e6b0c3021aedb8f5a86f75276ee6fc7ff46e67e98e716728326102e91c9"

    account = Laksa::Account::Account.new(private_key)
    
    public_key = '04163fa604c65aebeb7048c5548875c11418d6d106a20a0289d67b59807abdd299d4cf0efcf07e96e576732dae122b9a8ac142214a6bc133b77aa5b79ba46b3e20'
    address = 'ad5744c0c6246d9704592116fccbf41978fe99c8'

    assert_equal public_key, account.public_key
    assert_equal address, account.address
  end

  def test_from_file
    json = "{\"address\":\"B5C2CDD79C37209C3CB59E04B7C4062A8F5D5271\",\"crypto\":{\"cipher\":\"aes-128-ctr\",\"cipherparams\":{\"iv\":\"BB77D985DFF840E54EE52510DDF6FE38\"},\"ciphertext\":\"2064375F0A006F70381B180B4B25A139F18F19A40F24ACA9B30AC9E51488DFD4\",\"kdf\":\"pbkdf2\",\"kdfparams\":{\"n\":8192,\"c\":262144,\"r\":8,\"p\":1,\"dklen\":32,\"salt\":[119,19,15,64,53,-57,27,-111,36,105,-72,36,-59,5,-128,77,41,113,-78,-60,66,-102,-123,1,100,-45,-114,80,71,-16,-75,31]},\"mac\":\"8F00ED9E2C84C9387CBC70AE305DBE7B87F87CE106227C381E5EA928A265BB8F\"},\"id\":\"9b5e1a6d-54e1-43a2-8a10-49ab4e41b903\",\"version\":3}\n";
    account = Laksa::Account::Account.from_file(json, "xiaohuo")
    assert_equal '24180e6b0c3021aedb8f5a86f75276ee6fc7ff46e67e98e716728326102e91c9', account.private_key
  end

  def test_to_file
    private_key = '24180e6b0c3021aedb8f5a86f75276ee6fc7ff46e67e98e716728326102e91c9'
    account = Laksa::Account::Account.new(private_key)

    json = account.to_file('xiaohuo', Laksa::Crypto::KeyStore::T_PBKDF2)

    account_restore = Laksa::Account::Account.from_file(json, "xiaohuo")

    assert_equal private_key, account_restore.private_key
  end
end