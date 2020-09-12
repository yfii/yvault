# v2版的机枪池

主要是使用了iToken 

退出费0.1% 在strategy里面设置

## vault

用户充值 

1. depositAll   
2. deposit(uint _amount)

用户提现

1. withdrawAll
2. withdraw(uint _amount)

计算用户收入

持有的itoken * getPricePerFullShare()

## strategy

需要实现的方法

deposit:把vault的钱拿进去挖矿

withdraw(uint _amount):从挖矿合约里面取钱

withdrawAll:把挖矿合约里面的钱全部转移出来 且把钱转还到vault合约

setNewPool:(可选 如果某个系列特别多的话 可以用这个.是为了不需要来一个新的水果类的，就要重新部署strategy合约。。。)

harvest: 领取挖矿合约的代币 并且把收入分配出去...且再质押进去
- 目前是90%换成原来的token
- 10%换成yfii
    - 1% call fee
    - 1% 保险
    - 5% reward pool
    - 3% team

balanceOf: 有多少钱充进去挖矿了

harvertYFII: 未领取奖励换成yfii有多少.(需要未领取的奖励->换成yfii)


## controller 

0xcDCf1f9Ac816Fed665B09a00f60c885dd8848b02  test in prod的地址
