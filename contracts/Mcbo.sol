// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract MCBO {
    address public owner;
    uint256 private minimumTipAmount = 10**15;

    mapping(bytes32 => uint256) public balances;
    mapping(bytes32 => bool) private canClaim;

    constructor() {
        owner = msg.sender;
    }

    fallback() external payable {}

    receive() external payable {}

    modifier isOwner() {
        require(msg.sender == owner, "Permission denied.");
        _;
    }

    function sendTip(bytes32 _id) external payable {
        require(msg.value >= minimumTipAmount, "Tip too low.");
        balances[_id] += msg.value;
    }

    function claimTip(bytes32 _id) external payable {
        require(canClaim[_id], "You are not allowed to claim.");

        uint256 totalTips = balances[_id];

        balances[_id] = 0;

        (bool success, ) = payable(msg.sender).call{value: totalTips}("");

        require(success, "oh no!");
    }

    function allowClaim(bytes32 _id) external isOwner {
        canClaim[_id] = true;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
