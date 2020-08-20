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

interface CrvYvault{
    function withdraw(uint _shares) external;
}


interface UniswapRouter {
  function swapExactTokensForTokens(
      uint amountIn,
      uint amountOutMin,
      address[] calldata path,
      address to,
      uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
        ) external;
}

contract Swap {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    address public owner;
    
    constructor()public{
        owner = tx.origin;
    }
    modifier onlyOwner(){
        require(msg.sender == owner,"not owner");
        _;
    }

    address constant public yfii = address(0xa1d0E215a23d7030842FC67cE582a6aFa3CCaB83);
    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant public dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant public pasta = address(0x08A2E41FB99A7599725190B9C970Ad3893fa33CF);
    address constant public yycrv = address(0x5dbcF33D8c2E976c6b560249878e6F1491Bca25c);
    address constant public ycrv = address(0xdF5e0e81Dff6FAF3A7e52BA697820c5e32D806A8);
    
    
    
    function doswap(uint256 _amount) public {
        IERC20(pasta).safeApprove(unirouter, 0);
        IERC20(pasta).safeApprove(unirouter, uint(-1));
        address[] memory path2 = new address[](2);
        path2[0] = address(pasta);
        path2[1] = address(yycrv);
        UniswapRouter(unirouter).swapExactTokensForTokensSupportingFeeOnTransferTokens(IERC20(pasta).balanceOf(address(this)), 0, path2, address(this), now.add(1800));

        //yycrv-> yvault-> ycrv
        CrvYvault(yycrv).withdraw(IERC20(yycrv).balanceOf(address(this)));

        //ycrv -> weth-> yfii
        IERC20(ycrv).safeApprove(unirouter, 0);
        IERC20(ycrv).safeApprove(unirouter, uint(-1));
        address[] memory path3 = new address[](3);
        path3[0] = address(ycrv);
        path3[1] = address(weth);
        path3[2] = address(yfii);
        UniswapRouter(unirouter).swapExactTokensForTokens(IERC20(ycrv).balanceOf(address(this)), 0, path3, address(this), now.add(1800));
        
    }
    function inCaseTokenGetsStuck(IERC20 _TokenAddress) onlyOwner public {
          uint qty = _TokenAddress.balanceOf(address(this));
          _TokenAddress.safeTransfer(msg.sender, qty);
      }

  // incase of half-way error
      function inCaseETHGetsStuck() onlyOwner public{
          (bool result, ) = msg.sender.call.value(address(this).balance)("");
          require(result, "transfer of ETH failed");
      }
}