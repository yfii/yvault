/**
 *Submitted for verification at Etherscan.io on 2020-07-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint);
    function name() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface Controller {
    function vaults(address) external view returns (address);
    function rewards() external view returns (address);
}

/*

 A strategy must implement the following calls;
 
 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()
 
 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller
 
*/

interface Yam {
    function withdraw(uint) external;
    function getReward() external;
    function stake(uint) external;
    function balanceOf(address) external view returns (uint);
    function exit() external;
    function earned(address) external view returns (uint);
}

interface UniswapRouter {
  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external returns (uint[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

}


contract Strategy {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public pool;
    address public output;
    string public getName;

    address constant public yfii = address(0xa1d0E215a23d7030842FC67cE582a6aFa3CCaB83);
    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant public ycrv = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    
    uint public fee = 400; //300 + 100
    uint public callfee = 100;
    uint public burnfee = 500;
    uint constant public max = 1000;


    uint public withdrawalFee = 10;
    uint constant public withdrawalMax = 10000;
    
    address public governance;
    address public controller;

    address  public want;
    
    address[] public swap2YFIIRouting;
    address[] public swap2TokenRouting;
    
    constructor(address _output,address _pool,address _want) public {
        governance = tx.origin;
        controller = 0xe14e60d0F7fb15b1A98FDE88A3415C17b023bf36;
        output = _output;
        pool = _pool;
        want = _want;
        getName = string(
            abi.encodePacked("yfii:Strategy:", 
                abi.encodePacked(IERC20(want).name(),
                    abi.encodePacked(":",IERC20(output).name())
                )
            ));
        doApprove(); 
        swap2YFIIRouting = [output,ycrv,weth,yfii];
        swap2TokenRouting = [output,ycrv,want]; 

    }
    
    function deposit() public { 
        IERC20(want).safeApprove(pool, 0);
        IERC20(want).safeApprove(pool, IERC20(want).balanceOf(address(this)));
        Yam(pool).stake(IERC20(want).balanceOf(address(this)));
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "!controller");
        require(want != address(_asset), "want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }

        uint _fee = _amount.mul(withdrawalFee).div(withdrawalMax);        
        IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() public returns (uint balance) { 
        require(msg.sender == controller||msg.sender==governance, "!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
        
    }
    
    function _withdrawAll() internal { 
        Yam(pool).exit();
    }
    function doApprove () public{
        IERC20(output).safeApprove(unirouter, uint(-1));
    }

    function setNewPool(address _output,address _pool) public{
        require(msg.sender == governance, "!governance");
        //这边是切换池子以及挖到的代币
        //先退出之前的池子.
        harvest();
        withdrawAll();
        output = _output;
        pool = _pool;
        getName = string(
            abi.encodePacked("yfii:Strategy:", 
                abi.encodePacked(IERC20(want).name(),
                    abi.encodePacked(":",IERC20(output).name())
                )
            ));

    }
    
    function harvest() public {
        require(!Address.isContract(msg.sender),"!contract");
        Yam(pool).getReward(); 
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "!vault"); // additional protection so we don't burn the funds

        doswap();
        // fee
        uint b = IERC20(yfii).balanceOf(address(this));
        uint _fee = b.mul(fee).div(max);
        uint _callfee = b.mul(callfee).div(max);
        uint _burnfee = b.mul(burnfee).div(max);
        IERC20(yfii).safeTransfer(Controller(controller).rewards(), _fee); //4%  3% team +1% insurance
        IERC20(yfii).safeTransfer(msg.sender, _callfee); //call fee 1%
        //TODO:把销毁地址改为 reward pool地址
        IERC20(yfii).safeTransfer(address(0x6666666666666666666666666666666666666666), _burnfee); //burn fee 5%

        deposit();
        
    }

    function doswap() internal {
            //output -> eth ->yfii
            uint256 _2token = IERC20(output).balanceOf(address(this)).mul(90).div(100); //90%
            uint256 _2yfii = IERC20(output).balanceOf(address(this)).mul(10).div(100);  //10%
            UniswapRouter(unirouter).swapExactTokensForTokens(_2token, 0, swap2TokenRouting, address(this), now.add(1800));
            UniswapRouter(unirouter).swapExactTokensForTokens(_2yfii, 0, swap2YFIIRouting, address(this), now.add(1800));

    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        Yam(pool).withdraw(_amount);
        return _amount;
    }
    
    
    function balanceOf() public view returns (uint) {
        return Yam(pool).balanceOf(address(this));
               
    }
    function balanceOfPendingReward() public view returns(uint){ //还没有领取的收益有多少...
        return Yam(pool).earned(address(this));
    }

    function harvertYFII() public view returns(uint[] memory amounts){ //未收割的token 能换成多少yfii
        uint _pendingReward = balanceOfPendingReward().mul(10).div(100); //10%
        return UniswapRouter(unirouter).getAmountsOut(_pendingReward,swap2YFIIRouting);
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "!governance");
        controller = _controller;
    }

    function setFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        fee = _fee;
    }
    function setCallFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        callfee = _fee;
    }    
    function setBurnFee(uint256 _fee) external{
        require(msg.sender == governance, "!governance");
        burnfee = _fee;
    }
    function setswap2YFIIRouting(address[] memory _path) public{
        require(msg.sender == governance, "!governance");
        swap2YFIIRouting = _path;
    }
    function setswap2TokenRouting(address[] memory _path) public{
        require(msg.sender == governance, "!governance");
        swap2TokenRouting = _path;
    }
    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "!governance");
        withdrawalFee = _withdrawalFee;
    }
}