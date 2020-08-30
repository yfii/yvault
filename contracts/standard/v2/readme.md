# v2版的机枪池

主要是使用了iToken 

退出费0.1% 在strategy里面设置

## vault

用户充值 

1. depositAll   
2. deposit(uint _amount)

用户提现

1. withdrawAll
2. withdraw

计算用户收入

持有的itoken * getPricePerFullShare()

