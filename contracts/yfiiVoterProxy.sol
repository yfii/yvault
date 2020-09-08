/**
 *Submitted for verification at Etherscan.io on 2020-08-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface YFIIVAULT {
    function plyr_(address) external view returns (uint, uint,uint);
}

contract YfiiVoterProxy {
    
    IERC20 public constant yfii = IERC20(0xa1d0E215a23d7030842FC67cE582a6aFa3CCaB83);
    IERC20 public constant poo3 = IERC20(0xf1750B770485A5d0589A6ba1270D9FC354884D45);
    YFIIVAULT public constant vault = YFIIVAULT(0xf5a232b1325769E09B303D7292589a2C7AEe2Aa4);
    
    function decimals() external pure returns (uint8) {
        return uint8(18);
    }
    
    function name() external pure returns (string memory) {
        return "YFIIPOWAH";
    }
    
    function symbol() external pure returns (string memory) {
        return "YFII";
    }
    
    function totalSupply() external view returns (uint) {
        return yfii.totalSupply();
    }
    
    function balanceOf(address _voter) external view returns (uint) {
        (uint _votes,) = vault.plyr_(_voter);
        return _votes+yfii.balanceOf(_voter)+poo3.balanceOf(_voter);
    }    
}