## yVault

环境...
solc 0.5.15

```shell
brew install solidity@5
```

python 3

`pip install web3`

[ganache-cli](https://github.com/trufflesuite/ganache-cli)

目前生产合约都在 **contracts/standard**下面




## 机器池介绍

机枪池由3部分组成

Controller、vault、Strategy

Controller的作用是设置某个代币对应的vault以及Strategy

vault的作用是 用户充值，提现，领取奖励

Strategy的作用是 把用户充值的币接入各种收益率高的地方挖矿(Strategy是可以切换的)

生产用的合约在 [合约配置](https://raw.githubusercontent.com/yfii/yvault/master/contracts/standard/config.json)

abi文件参考 [vault](abi/vault.json)
abi文件参考 [Strategy](abi/strategy.json)

## 用户端

