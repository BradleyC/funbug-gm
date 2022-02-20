// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFUNBUGgm {
    function resolveIncent(address add1, address add2, uint256 count) external returns (bool);
}

contract GovernIncent {
    // Name: Bounty
    // System: Scorekeeping
    // Description: When it rains, it pours
    // Author: @bradleyc

    address Gm;
    uint256 bountyReward = 200;
    uint256 bountyPunish = 1;

    constructor(address _Gm) {
        Gm = _Gm;
    }

    function receiveIncent(address initiate, address target, bool isReward) public pure {
        // if (isReward == true) {
        //     // IFUNBUGgm(Gm).resolveIncent(initiate, target, bountyReward);
        // }  else {
        //     // isReward = false
        //     // IFUNBUGgm(Gm).resolveIncent(initiate, target, bountyPunish);
        // }
        initiate;
        target;
        isReward;
        return;
    }
}
