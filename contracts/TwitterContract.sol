// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "hardhat/console.sol";

contract TwitterContract {
    struct Tweet {
        uint tweetId;
        string content;
        address author;
        uint timestamp;
    }

    struct Message {
        address sender; // Ethereum address of the sender
        address recipient; // Ethereum address of the recipient
        string content; // Content of the message
        uint timestamp; // Timestamp when the message was sent
    }

    struct User {
        address userAddress; // Ethereum address of the sender
        string name; // Name of the user
        string email; // Email of the user (consider privacy implications)
    }
    uint private tweetCount;

    Message[] private messages;
    User[] private users;

    // Check if Existing users
    mapping(address => bool) existingUsers;

    mapping(address => address[]) private followers; // An array that stores the addresses of all followers for a specific user.
    mapping(address => address[]) private followings; // An array that stores the addresses of all users a specific user is following.

    mapping(address => Tweet[]) private tweets; // An array that stores the Tweet of all users a specific.

    mapping(address => mapping(address => bool)) private accessControl;

    constructor() {}

    modifier checkIfUserExist(address _userAddress) {
        require(!existingUsers[msg.sender], "User already exist");
        _;
    }

    modifier checkIfTweetCountExceed(address _userAddress, uint _count) {
        uint totalCount = tweets[_userAddress].length;
        require(_count <= totalCount, "Tweet Count exceeds");
        _;
    }

    function registerUser(
        string calldata _name,
        string calldata _email
    ) public checkIfUserExist(msg.sender) {
        users.push(User(msg.sender, _name, _email));
        existingUsers[msg.sender] = true;
    }

    function fetchAlluser() public view returns (User[] memory) {
        return users;
    }

    function addTweet(string calldata content) public {
        require(bytes(content).length != 0, "Tweet cannot be empty");
        require(existingUsers[msg.sender], "User doesn't exist");
        uint tc = tweetCount + 1;
        tweets[msg.sender].push(
            Tweet(tc, content, msg.sender, block.timestamp)
        );
        tweetCount = tc;
    }

    function getTweetByUser() public view returns (Tweet[] memory) {
        return tweets[msg.sender];
    }

    function getTweetCount() public view returns (uint) {
        return tweetCount;
    }

    function getTweetByCount(
        uint _count
    )
        public
        view
        checkIfTweetCountExceed(msg.sender, _count)
        returns (Tweet[] memory)
    {
        // Tweet[] memory latestTweet = getTweetUtils(msg.sender, _count);
        return getTweetUtils(msg.sender, _count);
    }

    function getTweetByUserWithCount(
        address _user,
        uint _count
    )
        public
        view
        checkIfTweetCountExceed(_user, _count)
        returns (Tweet[] memory)
    {
        return getTweetUtils(_user, _count);
    }

    function getTweetUtils(
        address _user,
        uint _count
    ) private view returns (Tweet[] memory) {
        uint totalCount = tweets[_user].length;
        Tweet[] memory latestTweet = new Tweet[](totalCount);
        uint j = 0;
        for (uint index = _count; index > 0; index--) {
            Tweet memory ele = tweets[_user][index - 1];
            latestTweet[j] = ele;
            j++;
        }
        return latestTweet;
    }
}
