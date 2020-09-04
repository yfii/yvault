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

## abi

### 操作
`function deposit(uint amount)` 用户入金  需要先对vault合约进行代币授权

`function withdraw(uint amount)` 用户提现

### 读

`function balanceOf(address user) public view returns (uint256)` 查看用户有的iToken数量

`function getPricePerFullShare() public view returns (uint)`  查看每个iToken换回原来token的比例

这边返回的值需要 除以1e18

可以换回原来代币的数量为: 用户持有的iToken数量*getPricePerFullShare/1e18 

