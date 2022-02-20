// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFUNBUGgm {
    function resolveIncent(address add1, address add2, uint256 count, address gameWallet) external returns (bool);
}

contract GovernIncent {
    // Name: Bounty
    // System: Scorekeeping
    // Description: When it rains, it pours
    // Author: @bradleyc
    // this contract simply forwards a call to change a token balance based on hardcoded values.
    // In reality, this logic could get quite complex.

    address Gm;
    uint256 bountyReward = 200;
    uint256 bountyPunish = 1;

    constructor(address _Gm) {
        Gm = _Gm;
    }

    function receiveIncent(address initiate, address target, bool isReward, address gameWallet) public {
        if (isReward == true) {
            IFUNBUGgm(Gm).resolveIncent(initiate, target, bountyReward, gameWallet);
        }  else {
            // isReward = false;
            IFUNBUGgm(Gm).resolveIncent(initiate, target, bountyPunish, gameWallet);
        }
        return;
    }
}
