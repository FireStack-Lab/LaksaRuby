require 'test_helper'

class Bech32Test < Minitest::Test
  def test_to_bech32
    assert_equal 'zil1r5verznnwvrzrz6uhveyrlxuhkvccwnju4aehf', Laksa::Util::Bech32.to_bech32('1d19918a737306218b5cbb3241fcdcbd998c3a72')
    assert_equal 'zil1ej8wy3mnux6t9zeuc4vkhww0csctfpznzt4s76', Laksa::Util::Bech32.to_bech32('cc8ee24773e1b4b28b3cc5596bb9cfc430b48453')
    assert_equal 'zil1u9zhd9zyg056ajn0z269f9qcsj4py2fc89ru3d', Laksa::Util::Bech32.to_bech32('e14576944443e9aeca6f12b454941884aa122938')
    assert_equal 'zil1z7fkzy2vhl2nhexng50dlq2gehjvlem5w7kx8z', Laksa::Util::Bech32.to_bech32('179361114cbfd53be4d3451edf8148cde4cfe774')
    assert_equal 'zil1tg4kvl77kc6kt9mgr5y0dntxx6hdj3uy95ash8', Laksa::Util::Bech32.to_bech32('5a2b667fdeb6356597681d08f6cd6636aed94784')
    assert_equal 'zil12de59e0q566q9u5pu26rqxufzgawxyghq0vdk9', Laksa::Util::Bech32.to_bech32('537342e5e0a6b402f281e2b4301b89123ae31117')
    assert_equal 'zil1tesag25495klra89e0kh7lgjjn5hgjjj0qmu8l', Laksa::Util::Bech32.to_bech32('5e61d42a952d2df1f4e5cbed7f7d1294e9744a52')
    assert_equal 'zil1tawmrsvvehn8u5fm0aawsg89dy25ja46ndsrhq', Laksa::Util::Bech32.to_bech32('5f5db1c18ccde67e513b7f7ae820e569154976ba')
  end

  def test_from_bech32
    assert_equal '4BAF5FADA8E5DB92C3D3242618C5B47133AE003C', Laksa::Util::Bech32.from_bech32('zil1fwh4ltdguhde9s7nysnp33d5wye6uqpugufkz7').upcase
    assert_equal '448261915A80CDE9BDE7C7A791685200D3A0BF4E', Laksa::Util::Bech32.from_bech32('zil1gjpxry26srx7n008c7nez6zjqrf6p06wur4x3m').upcase
    assert_equal 'DED02FD979FC2E55C0243BD2F52DF022C40ADA1E', Laksa::Util::Bech32.from_bech32('zil1mmgzlktelsh9tspy80f02t0sytzq4ks79zdnkk').upcase
    assert_equal '13F06E60297BEA6A3C402F6F64C416A6B31E586E', Laksa::Util::Bech32.from_bech32('zil1z0cxucpf004x50zq9ahkf3qk56e3ukrwaty4g8').upcase
    assert_equal '1A90C25307C3CC71958A83FA213A2362D859CF33', Laksa::Util::Bech32.from_bech32('zil1r2gvy5c8c0x8r9v2s0azzw3rvtv9nnenynd33g').upcase
    assert_equal '625ABAEBD87DAE9AB128F3B3AE99688813D9C5DF', Laksa::Util::Bech32.from_bech32('zil1vfdt467c0khf4vfg7we6axtg3qfan3wlf9yc6y').upcase
    assert_equal '36BA34097F861191C48C839C9B1A8B5912F583CF', Laksa::Util::Bech32.from_bech32('zil1x6argztlscger3yvswwfkx5ttyf0tq703v7fre').upcase
    assert_equal 'D2453AE76C9A86AAE544FCA699DBDC5C576AEF3A', Laksa::Util::Bech32.from_bech32('zil16fzn4emvn2r24e2yljnfnk7ut3tk4me6qx08ed').upcase
    assert_equal '72220E84947C36118CDBC580454DFAA3B918CD97', Laksa::Util::Bech32.from_bech32('zil1wg3qapy50smprrxmckqy2n065wu33nvh35dn0v').upcase
    assert_equal '50F92304C892D94A385CA6CE6CD6950CE9A36839', Laksa::Util::Bech32.from_bech32('zil12rujxpxgjtv55wzu5m8xe454pn56x6pedpl554').upcase
  end
end