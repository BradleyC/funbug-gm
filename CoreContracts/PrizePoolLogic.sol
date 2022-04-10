// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// @notice This contract manages changes to Funbugᵍᵐ token.
interface IFUNBUGgm {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

// External interface/schema needs for external GM calcs
interface IRektGame {
    function createNew(uint256 startTime) external payable;
    function action(uint id) external payable;
    function finalize(uint id) external;
    function withdrawFees(uint256 amount) external;
}

contract PrizePoolLogic is OwnableUpgradeable, UUPSUpgradeable {

    struct Pool {
        // remove owner
        address owner;
        // account - address of game contract 
        address account;
        // TODO: add gameId from registrar
        uint256 poolId;
        // balance of the individual game's pool
        uint256 poolBalance;
        uint256 createdAt;
    }

    address Gm;
    address registrar;
    uint poolCreateFee = 0.01 ether;
    uint gmEthRatio = 1 gwei;
    uint256 currentPoolId;
    Pool[] public pools;

    event PoolCreated(address indexed owner, address indexed account, uint indexed id);
    event PoolDeposit(address indexed owner, uint indexed id, uint depositTotal);
    event PoolWithdraw(address indexed owner, uint indexed id, uint withdrawTotal);

    constructor() initializer {}

    function initialize(address _Gm, address _registrar) initializer public {
        registrar = _registrar;
        Gm = _Gm;
    }

    function createPool(address gameContract) external payable {
        require(msg.value == poolCreateFee, 'Must attach pool fee');
        uint256 poolId = currentPoolId;
        pools.push(Pool(msg.sender, gameContract, poolId, 0, block.timestamp));
        uint id = pools.length - 1;
        currentPoolId++;

        // IRektGame(gameContract).createNew(block.timestamp);

        emit PoolCreated(msg.sender, gameContract, id);
    }

    function poolAction(uint id) external payable {
        // IRektGame(pools[id].account).action(id);
    }

    function poolFinalize(uint id) external payable {
        // IRektGame(pools[id].account).finalize(id);
    }

    // Deposit GM token
    function receiveDeposit(uint256 id, uint256 value) external {
        uint256 currentBal = pools[id].poolBalance;
        pools[id].poolBalance = currentBal + value;
    }

    // Award GM token
    function awardPool(uint256 poolId, address recipient) external {
        require(pools[poolId].owner == msg.sender, '');
        uint256 totalBal = pools[poolId].poolBalance;
        // 50% remains
        uint256 currentPayout = totalBal / 2;
        // 80% to winner
        uint256 winnings = currentPayout * 8 / 10;
        // IFUNBUGgm(Gm).transfer(recipient, winnings);
        // 10% to global prize pool
        uint256 globalPool = currentPayout * 1 / 10;
        pools[0].poolBalance = pools[0].poolBalance + globalPool;
        // 10% rake
        uint256 rake = currentPayout * 1 / 10;
        // IFUNBUGgm(Gm).transfer(Gm, rake);
    }

    function withdrawAll() public {
        uint256 amount = address(this).balance;
        require(payable(owner()).send(amount));
    }
}
