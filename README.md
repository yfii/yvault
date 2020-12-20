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

机枪池由 3 部分组成

Controller、vault、Strategy

Controller 的作用是设置某个代币对应的 vault 以及 Strategy

vault 的作用是 用户充值，提现，领取奖励

Strategy 的作用是 把用户充值的币接入各种收益率高的地方挖矿(Strategy 是可以切换的)

生产用的合约在 [合约配置](https://raw.githubusercontent.com/yfii/yvault/master/contracts/standard/config.json)

[vault](abi/vault.json) abi 文件参考
[Strategy](abi/strategy.json) abi 文件参考

## abi

### 操作（Write SmartContract)

`function deposit(uint amount)` 用户入金 需要先对 vault 合约进行代币授权

`function withdraw(uint amount)` 用户提现

### 读 (Read SmartContract)

`function balanceOf(address user) public view returns (uint256)` 查看用户有的 iToken 数量

`function getPricePerFullShare() public view returns (uint)` 查看每个 iToken 换回原来 token 的比例

这边返回的值需要 除以 1e18

可以换回原来代币的数量为: 用户持有的 iToken 数量\*getPricePerFullShare/1e18
