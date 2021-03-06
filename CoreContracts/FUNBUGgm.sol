// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

interface IGovernIncent {
    function receiveIncent(address initiate, address target, bool isReward) external;
}

contract FUNBUGgm is ERC20, ERC20FlashMint {
    address funbugRegistrar;

    constructor(address _funbugRegistrar) ERC20("FUNBUGgm", "FBgm") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
        funbugRegistrar = _funbugRegistrar;
        transfer(msg.sender, 250000);
        transfer(0x7427DECbadcEF0e1F1B9417Cd358C994F3b1b9C5, 250000);
    }

    function setFunbugRegistrarAddress(address newRegistrar) public returns(bool) {
        funbugRegistrar = newRegistrar;
        return true;
        // emit event
    }

    function resolveIncent(address add1, address add2, uint256 count) private returns (bool) {
        if (add2 == address(0x0)) {
            transfer(add1, count);
        } else {
            transferFrom(add1, add2, count);
        }
        return true;
    }

}