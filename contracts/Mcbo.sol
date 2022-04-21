// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract MCBO {
    address public owner;
    uint256 private minimumTipAmount = 10**15;
    uint256 public userCount = 0;

    struct User {
        bool isVerified;
        bytes32 token;
        uint256 id;
        address wallet;
    }

    mapping(bytes32 => uint256) public balances;
    mapping(address => bool) private canClaim;
    mapping(uint256 => User) private users;

    constructor() {
        owner = msg.sender;
    }

    fallback() external payable {}

    receive() external payable {}

    modifier isOwner() {
        require(msg.sender == owner, "Permission denied.");
        _;
    }

    function sendTip(bytes32 _token) external payable {
        require(msg.value >= minimumTipAmount, "Tip too low.");
        balances[_token] += msg.value;
    }

    function sendTipToUser(uint256 _id) external payable {
        (bool _isVerified, bytes32 _token, ) = getUser(_id);

        require(_isVerified, "User does not exist.");
        require(msg.value >= minimumTipAmount, "Tip too low.");

        balances[_token] += msg.value;
    }

    function claimTip(bytes32 _token) external payable {
        require(canClaim[msg.sender], "You are not allowed to claim.");

        uint256 totalTips = balances[_token];

        balances[_token] = 0;

        (bool success, ) = payable(msg.sender).call{value: totalTips}("");

        require(success, "Transfer failed.");
    }

    function allowClaim(address _wallet) external isOwner {
        canClaim[_wallet] = true;
    }

    function createUser(bytes32 _token) external isOwner {
        users[userCount] = User(true, _token, userCount, address(0));

        userCount += 1;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUser(uint256 _id)
        private
        view
        returns (
            bool,
            bytes32,
            address
        )
    {
        bool _isVerified = users[_id].isVerified;
        bytes32 _token = users[_id].token;
        address _wallet = users[_id].wallet;

        return (_isVerified, _token, _wallet);
    }
}
