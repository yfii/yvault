# yVault


## Controller

earn -> Strategy.deposit

withdrawall-> Strategy.withdrawall

withdraw  -> Strategy.withdraw

balanceOf -> Strategy.balanceOf


## yvault:

earn -> Controller.earn

deposit:用户存钱

withdraw:用户取钱。（钱不够触发。 Controller.withdraw

claim: 用户领取分红

make_profit: Strategy.harvest 触发分红.

cal_out: 某个用户可领取的分红

cal_out_pending: 某个用户在路上的分红（也就是分红还没有从挖矿合约领取.只能看到，无法领取，等harvest触发后就可以领取了）

balanceOf: token.balanceOf(address(this)) + Controller.balanceOf (也就是TVL)

## Strategy

deposit: 存钱到某个合约 获取利息啥的

withdraw: 从某个合约取钱出来

withdrawall:  把所有的钱从挖矿合约退出.

harvest: 领取分红.

balanceOf: 存放在挖矿合约里面的钱

balanceOfPendingReward：还未从挖矿合约领取的收益.


## yam 相关合约

yam:0x0e2298E3B3390e3b945a5456fBf59eCc3f55DA16

wethpool:0x587A07cE5c265A38Dd6d42def1566BA73eeb06F5  weth:0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2
snxpool:0x6c3FC1FFDb14D92394f40eeC91D9Ce8B807f132D   snx:0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F
lendpool:0x6009A344C7F993B16EBa2c673fefd2e07f9be5FD  lend:0x80fB784B7eD66730e8b1DBd9820aFD29931aab03
mkrpool:0xcFe1E539AcB2D489a651cA011a6eB93d32f97E23   mkr:0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2
amplpool:0x9EbB67687FEE2d265D7b824714DF13622D90E663   ampl_lp:0xc5be99A02C6857f9Eac67BbCE58DF5572498F40c
yfipool:0xc5B6488c7D5BeD173B76Bd5DCA712f45fB9EaEaB    yfi:0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e
linkpool:0xFDC28897A1E32B595f1f4f1D3aE0Df93B1eee452   link:0x514910771AF9Ca656af840dff83E8264EcF986CA
comppool:0x8538E5910c6F80419CD3170c26073Ff238048c9E  comp:0xc00e94Cb662C3520282E6f5717214004A7f26888

