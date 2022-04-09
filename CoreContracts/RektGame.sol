// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// TODO: Add external interface/schema needs for external GM calcs
contract RektGame {
    struct Rekt {
        address[] bets;
        uint256 brokenClock;
        uint256 prevDuration;
        uint256 rektTotal;
        uint32 callIndex;
        address admin;
    }

    address Gm;
    address owner;
    uint betFee = 0.001 ether;
    uint rektCreateFee = 0.01 ether;
    uint256 timeOffsetBase = 1000 * 60 * 60;
    uint32 timeExponent = 1200;
    Rekt[] public rekts;

    event RektCreated(address indexed owner, uint indexed id);
    event RektBet(address indexed loser, uint indexed id, uint rektTotal);
    event RektFinished(address indexed owner, uint indexed id, uint rektTotal);

    constructor(address _Gm) {
        owner = msg.sender;
        Gm = _Gm;
    }

    // Internal Skale RNG endpoint
    function getRandom() public view returns (bytes32 addr) {
        assembly {
            let freemem := mload(0x40)
            let start_addr := add(freemem, 0)
            if iszero(staticcall(gas(), 0x18, 0, 0, start_addr, 32)) {
              invalid()
            }
            addr := mload(freemem)
        }
    }

    function createNew(uint64 startTime) external payable {
        require(msg.value == rektCreateFee, 'Must attach rekt fee');
        address[] memory bets;
        uint id = rekts.push(Rekt(bets, startTime, timeOffsetBase, 0, 0, msg.sender)) - 1;

        emit RektCreated(msg.sender, id);
    }

    // - bet
    function action(uint id) external payable {
        require(id != 0, 'ID must be specified');
        require(msg.value == betFee, 'Must attach bet fee');
        Rekt storage p = rekts[id];

        // check if rekt has timed out
        require(p.brokenClock < block.timestamp, 'Rekt has timed out, no more bets');

        // reset timer, add totals for the bets
        // TODO:
        bytes32 ranStr = getRandom();
        uint256 ranTime = uint256(uint8(ranStr));
        p.prevDuration = p.prevDuration + (ranTime * timeOffsetBase);
        p.brokenClock = block.timestamp + p.prevDuration;
        p.callIndex += 1;
        p.rektTotal += (msg.value - betFee);
        p.bets.push(msg.sender);

        // update storage
        rekts[id] = p;

        emit RektBet(msg.sender, id, p.rektTotal);
    }

    // - finalize
    function finalize(uint id) external {
        require(id != 0, 'ID must be specified');
        // Anyone can call? As long as teh rekt has ended, it will pay the winner.
        // require(msg.sender == owner, 'Must be owner');
        
        // call transfer to winner(s)?
        Rekt memory p = rekts[id];
        require(p.brokenClock > block.timestamp, 'Rekt has not ended yet');

        // Last bet wins!
        // NOTE: this could change to do multiple
        address winner = p.bets[p.bets.length - 1];
        require(payable(winner).send(p.rektTotal));
        emit RektFinished(winner, id, p.rektTotal);
    }

    function withdrawFees(uint256 amount) external {
        require(msg.sender == owner, 'Must be owner');
        require(amount > 1 gwei, 'Amount must be more than 1 gwei');
        require(amount < address(this).balance, 'Amount must be less than total available balance');

        // call transfer to owner
        require(payable(owner).send(amount));
    }
}
