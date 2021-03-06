// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// 🕯 INTERFACES
// @dev All necessary inter-contract communication goes here.

// @notice This contract manages changes to Funbugᵍᵐ token.
interface IFUNBUGgm {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

// @notice This contract determines the logic circuit used to control Funbugᵍᵐ token.
interface IGovernIncent {
    function receiveIncent(address initiate, address target, bool isReward) external;
}

// @notice This contract determines the logic circuit used to control a game's soft currency token.
interface ISugarIncent {
    function receiveIncent(address initiate, address target, bool isReward) external;
}

// TODO: OwnedProperty Interface
// TODO: PrizePool Interface

contract FunbugRegistrar is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    // 🕯 ADDRESSES
    // Address of core contracts. Should only ever change rarely.
    address FUNBUGgm;
    address FunbugInventory;

    // 🕯 DEFAULTS
    // The default settings 
    address governIncentAddress;
    address sugarIncentAddress;
    address ownedPropertyAddress;
    address prizePoolLogicAddress;
    uint256 seedTokens;
    uint256 depositPrice;
    uint256 currentGameCount;

    struct FunbugGame {
        // game ID
        uint256 gameId;
        // prize pool per game, optional
        uint256 prizePoolId;
        // logic circuit to use for awarding the prize pool
        address prizePoolLogicAddress;
        // logic circuit to use for hard currency incentives
        address governIncentAddress;
        // logic circuit to use for soft currency incentives
        address sugarIncentAddress;
        // logic circuit to used to manage NFTs
        address ownedPropertyAddress;
    }

    mapping(address => FunbugGame) public funbugRegistry;
 
    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
        seedTokens = 5000;
        depositPrice = 5000000000000000000;
        currentGameCount = 0;
    }

    // 🕯 A SMALL SEANCE
    // Create a new game
    function createFunbugGame(
        address _governIncentAddress,
        address _sugarIncentAddress,
        address _ownedPropertyAddress,
        address _prizePoolLogicAddress
    ) public payable {
        require(msg.value >= depositPrice, 'MUST PAY COMPLETE DEPOSIT TO INSTANTIATE GAME');
        address gameOwner = msg.sender;
        FunbugGame storage _funbugGame = funbugRegistry[msg.sender];
        _funbugGame.gameId = currentGameCount;
        setPrizePoolId();
        setPrizePoolLogicAddress(_prizePoolLogicAddress);
        setGovernIncentAddress(_governIncentAddress);
        setSugarIncentAddress(_sugarIncentAddress);
        setOwnedPropertyAddress(_ownedPropertyAddress);
        // transfer Funbugᵍᵐ to registrant's wallet
        IFUNBUGgm(FUNBUGgm).transfer(gameOwner, seedTokens);
        // as long as funds remain in your wallet, they are considered deposited in Funbugᵍᵐ ecosystem.
        // if you want custody of your game's Funbugᵍᵐ, move it to a different wallet.
        IFUNBUGgm(FUNBUGgm).approve(address(this), seedTokens);
        currentGameCount++;
        // TODO: fire event     
    }

    // 🕯 ROUTING
    // Send inbound calls to the appropriate logic circuit
    function governIncent(address initiate, address target, bool isReward) public {
        address _governIncentAddress = getGovernIncentAddress();
        IGovernIncent(_governIncentAddress).receiveIncent(initiate, target, isReward);
    }

    function sugarIncent(address initiate, address target, bool isReward) public {
        address _sugarIncentAddress = getSugarIncentAddress();
        ISugarIncent(_sugarIncentAddress).receiveIncent(initiate, target, isReward);
    }
        // TODO: 
        // - ownedProperty - NFT controller
        // - prizePool - shared lottery

    // 🕯 GETTERS
    // Methods to account for using address to index a mapping of structs
    function getPrizePoolId() public view returns (uint256) {
        FunbugGame memory funbugGame = funbugRegistry[msg.sender];
        return funbugGame.prizePoolId;
    }
    
    function getPrizePoolLogicAddress() public view returns (address) {
        FunbugGame memory funbugGame = funbugRegistry[msg.sender];
        return funbugGame.prizePoolLogicAddress;
    }
    
    function getGovernIncentAddress() public view returns (address) {
        FunbugGame memory funbugGame = funbugRegistry[msg.sender];
        return funbugGame.governIncentAddress;
    }
    
    function getSugarIncentAddress() public view returns (address) {
        FunbugGame memory funbugGame = funbugRegistry[msg.sender];
        return funbugGame.sugarIncentAddress;
    }
    
    function getOwnedPropertyAddress() public view returns (address) {
        FunbugGame memory funbugGame = funbugRegistry[msg.sender];
        return funbugGame.ownedPropertyAddress;
    }

    // 🕯 SETTERS
    // Setters can only trigger updates on the game that matches the wallet they sign with.
    // Community can trigger these actions through a multisig, for example.
    function setPrizePoolLogicAddress(address newPrizePoolLogicAddress) public {
        FunbugGame storage _funbugGame = funbugRegistry[msg.sender];
        _funbugGame.prizePoolLogicAddress = newPrizePoolLogicAddress;
    }

    function setGovernIncentAddress(address newGovernIncentAddress) public {
        FunbugGame storage funbugGame = funbugRegistry[msg.sender];
        funbugGame.governIncentAddress = newGovernIncentAddress;
    }

    function setSugarIncentAddress(address newSugarIncentAddress) public {
        FunbugGame storage funbugGame = funbugRegistry[msg.sender];
        funbugGame.sugarIncentAddress = newSugarIncentAddress;
    }

    function setOwnedPropertyAddress(address newOwnedPropertyAddress) public {
        FunbugGame storage funbugGame = funbugRegistry[msg.sender];
        funbugGame.ownedPropertyAddress = newOwnedPropertyAddress;
    }

    function setPrizePoolId() internal {
        FunbugGame storage funbugGame = funbugRegistry[msg.sender];
        funbugGame.prizePoolId = currentGameCount;
    }

    // 🕯 UTILITY
    // @dev functions for contract maintenance
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function withdrawAll() public {
        uint256 amount = address(this).balance;
        require(payable(owner()).send(amount));
    }

    function withdrawSip(uint256 withdraw) public onlyOwner {
        uint256 amount = withdraw;
        require(payable(owner()).send(amount));
    }
}

