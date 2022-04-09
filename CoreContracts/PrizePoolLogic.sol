// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// TODO: Add external interface/schema needs for external GM calcs
contract PrizePoolGn {
    struct Pool {
        address[] bets;
        uint256 brokenClock;
        uint256 prevDuration;
        uint64 poolTotal;
        uint32 callIndex;
        address admin;
    }

    address Gm;
    address owner;
    uint betFee = 0.001 ether;
    uint poolCreateFee = 0.01 ether;
    uint256 timeOffsetBase = 1000 * 60 * 60;
    uint32 timeExponent = 1200;
    Pool[] public pools;

    event PoolCreated(address indexed owner, uint indexed id);
    event PoolBet(address indexed loser, uint indexed id, uint poolTotal);
    event PoolFinalized(address indexed owner, uint indexed id, uint poolTotal);

    constructor(address _Gm) {
        owner = msg.sender;
        Gm = _Gm;
    }

    // Internal Skale RNG endpoint
    function getRandom() public view returns (bytes32 addr) {
        assembly {
            let freemem := mload(0x40)
            let start_addr := add(freemem, 0)
            if iszero(staticcall(gas, 0x18, 0, 0, start_addr, 32)) {
              invalid()
            }
            addr := mload(freemem)
        }
    }

    function createPool(uint64 startTime) external payable {
        require(msg.value == poolCreateFee, 'Must attach pool fee');
        uint id = pools.push(Pool([], block.timestamp, timeOffsetBase, 0, 0, msg.sender)) - 1;

        emit PoolCreated(msg.sender, id);
    }

    // - bet
    function bet(uint id) external payable {
        require(id != 0, 'ID must be specified');
        require(msg.value == betFee, 'Must attach bet fee');
        Pool memory p = pools[id];

        // check if pool has timed out
        require(p.brokenClock < block.timestamp, 'Pool has timed out, no more bets');

        // reset timer, add totals for the bets
        bytes32 ranStr = getRandom();
        uint256 ranTime = uint256(uint8(ranStr));
        p.prevDuration = p.prevDuration + (ranTime * timeOffsetBase);
        p.brokenClock = block.timestamp + p.prevDuration;
        p.callIndex += 1;
        p.poolTotal += (msg.value - betFee);
        p.bets.push(msg.sender);

        // update storage
        pools[id] = p;

        emit PoolBet(msg.sender, id, poolTotal);
    }

    // - finalize
    function finalize(uint id) external {
        require(id != 0, 'ID must be specified');
        // Anyone can call? As long as teh pool has ended, it will pay the winner.
        // require(msg.sender == owner, 'Must be owner');
        
        // call transfer to winner(s)?
        Pool memory p = pools[id];
        require(p.brokenClock > block.timestamp, 'Pool has not ended yet');

        // Last bet wins!
        // NOTE: this could change to do multiple
        address winner = p.bets[p.bets.length - 1];
        require(payable(winner).send(p.poolTotal));
        emit PoolFinished(winner, id, p.poolTotal)
    }

    function withdrawFees(uint256 amount) external {
        require(msg.sender == owner, 'Must be owner');
        require(amount > 1 gwei, 'Amount must be more than 1 gwei');
        require(amount < address(this).balance, 'Amount must be less than total available balance');

        // call transfer to owner
        require(payable(owner).send(amount));
    }
}
