// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

interface IGovernIncent {
    function receiveIncent(address initiate, address target, bool isReward) external;
}

contract FUNBUGgm is ERC20, ERC20FlashMint {

    address GovernIncent;
    
    // will need game state object

    constructor() ERC20("FUNBUGgm", "BUGm") {
        _mint(msg.sender, 10000000 * 10 ** decimals());
    }

    function setGovernIncentAddress(address newGovernor) public returns(bool) {
        GovernIncent = newGovernor;
        return true;
        // emit event
    }

    function incent(address initiate, address target, bool isReward) private {
        IGovernIncent(GovernIncent).receiveIncent(initiate, target, isReward);
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