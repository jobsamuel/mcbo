// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract MCBO {
    uint256 private constant MINIMUM_TIP_AMOUNT = 10**15;

    mapping(bytes32 => uint256) public balances;

    fallback() external payable {}

    receive() external payable {}

    function sendTip(bytes32 _id) external payable {
        require(msg.value >= MINIMUM_TIP_AMOUNT, "Tip too low.");
        balances[_id] += msg.value;
    }

    // TODO: handle claim allowance.
    function claimTip(bytes32 _id) external payable {
        uint256 totalTips = balances[_id];

        balances[_id] = 0;

        (bool success, ) = payable(msg.sender).call{value: totalTips}("");

        require(success, "oh no!");
    }

    // Only owner can allow address to claim.
    function allowClaim(address _to) external {}

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
