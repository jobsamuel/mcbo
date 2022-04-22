// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract MCBO {
    address public owner;
    uint256 private minimumTipAmount = 10**15;
    uint256 public userCount = 0;

    struct User {
        uint256 uid;
        bytes32 token;
        address payable wallet;
    }

    mapping(bytes32 => uint256) public balances;
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

    function sendTipToUser(uint256 _uid) external payable {
        (bytes32 _token, address _wallet) = getUser(_uid);

        require(_wallet != address(0), "User does not exist.");
        require(msg.value >= minimumTipAmount, "Tip too low.");

        balances[_token] += msg.value;
    }

    function transferTipToUserWallet(uint256 _uid) external payable isOwner {
        (bytes32 _token, address _wallet) = getUser(_uid);

        require(_wallet != address(0), "User does not exist.");
        require(_wallet != msg.sender, "Can not transfer balance.");

        uint256 totalTips = balances[_token];

        balances[_token] = 0;

        (bool success, ) = _wallet.call{value: totalTips}("");

        require(success, "Transfer failed.");
    }

    function createUser(bytes32 _token, address payable _wallet)
        external
        isOwner
    {
        users[userCount] = User(userCount, _token, _wallet);

        userCount += 1;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getUser(uint256 _uid) private view returns (bytes32, address) {
        bytes32 _token = users[_uid].token;
        address _wallet = users[_uid].wallet;

        return (_token, _wallet);
    }
}
