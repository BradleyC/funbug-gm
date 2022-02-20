// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFUNBUGgm {
    function resolveIncent(address add1, address add2, uint256 count) external returns (bool);
}

contract GovernIncent_Famine {
    // Name: Famine
    // System: Scorekeeping
    // Description: When times are tough, turn to your people for support
    // Author: @bradleyc
    
    address Gm;
    uint256 famineReward = 1;
    uint256 faminePunish = 200;

    constructor(address _Gm) {
        Gm = _Gm;
    }

    function receiveIncent(address initiate, address target, bool isReward) public {
        if (isReward == true) {
            IFUNBUGgm(Gm).resolveIncent(initiate, target, famineReward);
        }  else {
            // isReward = false
            IFUNBUGgm(Gm).resolveIncent(initiate, target, faminePunish);
        }
    }
}
