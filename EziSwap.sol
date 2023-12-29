// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EziSwap {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 public constant DECIMALS = 18;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Swap(address indexed from, address indexed to, address indexed token, uint256 value);
    event LiquidityAdded(address indexed provider, address indexed token, uint256 amount);
    event LiquidityRemoved(address indexed provider, address indexed token, uint256 amount);
    event FeeWithdrawn(address indexed admin, address indexed token, uint256 amount);

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admin can call this function");
        _;
    }

    constructor() {
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    function swap(address tokenAddress, address to, uint256 value) external {
        require(tokenAddress != address(0), "Invalid token address");
        require(to != address(0), "Invalid recipient address");

        IERC20 token = IERC20(tokenAddress);
        uint256 senderBalance = token.balanceOf(msg.sender);
        require(senderBalance >= value, "Insufficient balance");

        token.safeTransferFrom(msg.sender, address(this), value);
        _balances[to] += value;

        emit Swap(msg.sender, to, tokenAddress, value);
    }

    function addLiquidity(address tokenAddress, uint256 amount) external {
        require(tokenAddress != address(0), "Invalid token address");
        require(amount > 0, "Invalid liquidity amount");

        IERC20 token = IERC20(tokenAddress);
        uint256 senderBalance = token.balanceOf(msg.sender);
        require(senderBalance >= amount, "Insufficient balance");

        token.safeTransferFrom(msg.sender, address(this), amount);
        _balances[msg.sender] += amount;

        emit LiquidityAdded(msg.sender, tokenAddress, amount);
    }

    function removeLiquidity(address tokenAddress, uint256 amount) external {
        require(tokenAddress != address(0), "Invalid token address");
        require(amount > 0, "Invalid liquidity amount");

        uint256 liquidityBalance = _balances[msg.sender];
        require(liquidityBalance >= amount, "Insufficient liquidity");

        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(msg.sender, amount);
        _balances[msg.sender] -= amount;

        emit LiquidityRemoved(msg.sender, tokenAddress, amount);
    }

    function withdrawFee(address tokenAddress, uint256 amount) external onlyAdmin {
        require(tokenAddress != address(0), "Invalid token address");
        require(amount > 0, "Invalid amount to withdraw");

        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(msg.sender, amount);

        emit FeeWithdrawn(msg.sender, tokenAddress, amount);
    }

    // Other necessary functions for managing the contract...
}
