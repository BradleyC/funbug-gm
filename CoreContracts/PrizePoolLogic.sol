// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// @notice This contract manages changes to Funbugᵍᵐ token.
interface IFUNBUGgm {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// External interface/schema needs for external GM calcs
interface IRektGame {
    function createNew(uint256 startTime) external payable;
    function action(uint id) external payable;
    function finalize(uint id) external;
    function withdrawFees(uint256 amount) external;
}

abstract contract PrizePoolGn is Initializable, OwnableUpgradeable, UUPSUpgradeable {

    struct Pool {
        // remove owner
        address owner;
        // account - address of game contract 
        address account;
        uint256 issuedTotal;
        uint256 usedTotal;
        uint256 createdAt;
    }

    address Gm;
    address registrar;
    uint poolCreateFee = 0.01 ether;
    uint gmEthRatio = 1 gwei;
    Pool[] public pools;

    event PoolCreated(address indexed owner, address indexed account, uint indexed id);
    event PoolDeposit(address indexed owner, uint indexed id, uint depositTotal);
    event PoolWithdraw(address indexed owner, uint indexed id, uint withdrawTotal);

    constructor(address _Gm, address _registrar) {
        owner = msg.sender;
        registrar = _registrar;
        Gm = _Gm;
    }

    function createPool(address gameContract) external payable {
        require(msg.value == poolCreateFee, 'Must attach pool fee');
        pools.push(Pool(msg.sender, gameContract, 0, 0, block.timestamp));
        uint id = pools.length - 1;

        IRektGame(gameContract).createNew(block.timestamp);

        emit PoolCreated(msg.sender, gameContract, id);
    }

    function poolAction(uint id) external payable {
        IRektGame(pools[id].account).action(id);
    }

    function poolFinalize(uint id) external payable {
        IRektGame(pools[id].account).finalize(id);
    }

    // Deposit GM token
    function deposit(uint id) external payable {
        require(id != 0, 'ID must be specified');

        // Conversion ratio - deposit ETH get GM
        uint gm = msg.value / gmEthRatio;

        transferFrom(address(this), pools[id].owner, gm);
    }

    // Withdraw GM token
    function withdraw(uint id, uint256 amount) external {
        require(id != 0, 'ID must be specified');
        require(msg.sender == owner, 'Must be owner');

        // TODO: Check balance_of gm
        // Conversion ratio - withdraw GM get ETH
        uint eth = amount * gmEthRatio;

        transfer(pools[id].owner, eth);
    }

    function withdrawFees(uint256 amount) external {
        require(msg.sender == owner, 'Must be owner');
        require(amount > 1 gwei, 'Amount must be more than 1 gwei');
        require(amount < address(this).balance, 'Amount must be less than total available balance');

        // call transfer to owner
        require(payable(owner).send(amount));
    }
}
