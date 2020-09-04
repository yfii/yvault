## contract address

Controller: 0xe14e60d0F7fb15b1A98FDE88A3415C17b023bf36

## WETH

token: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

vault: 0xf693705e79ccc8707D3FcB4D89381CaC28e45a22

strategy: 0x602ec22B362B0E8ae658D18f4435fE8c5c23cA0C

## SNX

token: 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F

vault: 0xd4bEf8D8D8d7cBB89f63933Db6907439f9E6Fd0f

strategy:

## LEND

token: 0x80fB784B7eD66730e8b1DBd9820aFD29931aab03

vault: 0xA2D35bcDFc271767903f0Ed4aF56a066F6c99Ae7

strategy:

## MKR 

token:0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2

vault: 0x537350b9301fCf045Eaf1CEa2F225276C89D5f6D

strategy:

## YFI

token:0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e

vault: 0x4BD410A06FBB3A22C31017964D13Cbc5867d3d61

strategy:

## LINK

token:0x514910771AF9Ca656af840dff83E8264EcF986CA

vault: 0xCda9230923FCb25e26a20D7D9D12e1744405C9fC

strategy: 0x780c2450632ecb4be69DA859987Be4875545E90b

## COMP

token:0xc00e94Cb662C3520282E6f5717214004A7f26888

vault: 0x7AEFB9DCE3700B7CE8B1f556043BB1D436C77e0d

strategy:

## WBTC

token:0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599

vault: 0x2f4Ae3a95C7B457DB53706EEE8979aEca4ec0082

strategy:



## YCRV

token : 0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8

Strategy: 

- StrategyCRV:0x9eFE9FB2010B2c5fa7D34E69e709DD296d9c0bD9 
- StrategyPool1:  0x83612eAc340b967aD380feC9a2D50Ea3FcA1A2cb

vault:  0xD2db1EF55549eCdacb4e7da081216AE96f0Eedcb

Controller: 0xDE60d11E7cDBaC266Ad332DF289AD9dE2EE32e68(和上面的不一样)

## YFII

token: 0xa1d0E215a23d7030842FC67cE582a6aFa3CCaB83

Strategy: 0xe9bA312991e76116879b484135D2b86Ea27d0A0f v2

vault: 0xf5a232b1325769E09B303D7292589a2C7AEe2Aa4


## USDT 在测试.

token: 0xdAC17F958D2ee523a2206206994597C13D831ec7

Strategy:  0xe2df4c46acabb1cdb446351d6b24727944a5bfcc  dforce

vault: 0x72Cf258c852Dc485a853370171d46B9D29fD3184

## USDC

token: 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48

Strategy:

vault: 0x35a228bBe17F7c6D1ebaCc59fcA3aC6733135E63


## DAI 

token: 0x6B175474E89094C44Da98b954EedeAC495271d0F

Strategy: 0x6285FF6AEF7BA5Bddeb67B033dc75f6Da0980191

vault: 0x8FDD31b72Cc18c965E6a7BC85174994e72799732

## Curve.fi: cCrv Token (cDAI+cUSDC)

token: 0x845838DF265Dcd2c412A1Dc9e959c7d08537f8a2

Strategy: 0xEfb684AB29371e701CCe3CA9e3FD8f5E33042eee

vault: 0xf811c062D14fdF9Fda95D6A2C54e137afE80De45

## Curve.fi: bCrv Token (Curve.fi yDAI/yUSDC/yUSDT/yBUSD)

token: 0x3b3ac5386837dc563660fb6a0937dfaa5924333b

Strategy:

vault: 0xf4485B4f10C388d5b09DB36bA8adD2ceEA1E040B

## usdx/usdc lp dforce 

pool:https://cn.etherscan.com/address/0xa94e2074beb6d1bf28014b81ff2062eab3600c48#code

token: 0x460067f15e9B461a5F4c482E80217A2F45269385

Strategy: 

vault: 

## Strategy的标准接口

### deposit

```function deposit() external ```

质押代币到目标挖矿合约


    
### withdraw

```function withdraw(uint _amount) external```

从挖矿合约取出质押的钱
    
### withdrawAll

```function withdrawAll() public returns (uint balance) ```

提取目标挖矿合约里面所有的钱
    

### harvest

```function harvest() public```

从挖矿合约收取利息->换算成收益代币(yfii)->分钱

### balanceOf
    
``` function balanceOf() public view returns (uint)```

在目标合约存了多少钱.

### balanceOfPendingReward

```function balanceOfPendingReward() public view returns(uint)```

有多少分红没有领取
    
### harvertYFII

``` function harvertYFII() public view returns(uint[] memory amounts)```

balanceOfPendingReward 的数量换算成yfii的个数.
