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

    Message[] private messages;
    User[] private users;

    // Check if Existing users
    mapping(address => bool) existingUsers;

    mapping(address => address[]) private followers; // An array that stores the addresses of all followers for a specific user.
    mapping(address => address[]) private followings; // An array that stores the addresses of all users a specific user is following.

    // This is inefficient method but just considering it for both scenario.
    // mapping(address => Tweet[]) private tweetsByUser; // An array that stores the Tweet of all users a specific.
    Tweet[] private tweets; // An array that stores the Tweet of all users a specific.
    mapping(address => uint) tweetCountByUser;

    mapping(address => mapping(address => bool)) private accessControl;

    constructor() {}

    modifier checkIfUserExist(address _userAddress) {
        require(!existingUsers[_userAddress], "User already exist");
        _;
    }

    modifier checkIfUserDoesntExist(address _userAddress) {
        require(existingUsers[_userAddress], "User do not exist");
        _;
    }

    modifier checkIfUserIsAuthorize(address _userAddress) {
        require(accessControl[msg.sender][_userAddress], "Un-Authorize Access");
        _;
    }

    modifier checkIfTweetCountExceed(address _userAddress, uint _count) {
        uint totalCount = tweets.length;
        require(_count <= totalCount, "Tweet Count exceeds");
        _;
    }

    function registerUser(
        string calldata _name,
        string calldata _email
    ) public checkIfUserExist(msg.sender) {
        users.push(User(msg.sender, _name, _email));
        existingUsers[msg.sender] = true;
        accessControl[msg.sender][msg.sender] = true; // default flag to post the tweet
    }

    function fetchAlluser() public view returns (User[] memory) {
        return users;
    }

    function addTweet(
        string calldata content,
        address _authorizedUser
    ) public checkIfUserDoesntExist(msg.sender) checkIfUserIsAuthorize(_authorizedUser) {
        require(bytes(content).length != 0, "Tweet cannot be empty");
        uint tc = tweets.length + 1;
        tweets.push(Tweet(tc, content, msg.sender, block.timestamp));
        tweetCountByUser[msg.sender] = tweetCountByUser[msg.sender] + 1;
    }

    function getTweetCount() public view returns (uint) {
        return tweets.length;
    }

    // The latest tweets posted by users, considering a specified count.
    function getLatestTweetByCount(
        uint _count
    )
        public
        view
        checkIfTweetCountExceed(msg.sender, _count)
        returns (Tweet[] memory)
    {
        uint tweetCount = tweets.length;
        Tweet[] memory latestTweet = new Tweet[](_count);
        uint j = 0;
        for (uint index = tweetCount; j < _count; index--) {
            Tweet memory ele = tweets[index - 1];
            latestTweet[j] = ele;
            j++;
        }
        return latestTweet;
    }

    // Retrive the latest tweets of a specific user, considering a specified count.
    // The latest tweets of a specific user, considering a specified count.
    function getLatestTweetByUser(
        address _user,
        uint _count
    )
        public
        view
        checkIfTweetCountExceed(_user, _count)
        checkIfUserDoesntExist(_user)
        returns (Tweet[] memory)
    {
        // Check if user has number of tweets
        uint tweetCountByUsers = tweetCountByUser[msg.sender];
        require(
            _count <= tweetCountByUsers,
            "Your tweets are below the expected count."
        );
        uint tweetCount = tweets.length;
        Tweet[] memory latestTweet = new Tweet[](_count);
        uint j = 0;
        for (uint index = tweetCount; j < _count; index--) {
            Tweet memory ele = tweets[index - 1];
            if (ele.author == _user) {
                latestTweet[j] = ele;
                j++;
            }
        }
        return latestTweet;
    }

    // FOLLOW users
    // Develop a function that enables a user to follow another user by adding their address to a list of followed users.
    function followUser(
        address _followingUser
    ) public checkIfUserDoesntExist(msg.sender) {
        require(!existingUsers[_followingUser], "following user do not exist");
        address[] storage followingUser = followings[msg.sender];
        followingUser.push(_followingUser);
        address[] storage followedUser = followers[_followingUser];
        followedUser.push(msg.sender);
    }

    function fetchFollowers() public view returns (address[] memory) {
        return followers[msg.sender];
    }

    // Implement a function that enables users to send messages to other users. It should record the sender, recipient, message content, and creation timestamp.
    function sendMessage(
        address _recipient,
        string calldata _message,
        address _authorizedUser
    )
        public
        checkIfUserDoesntExist(msg.sender)
        checkIfUserDoesntExist(_recipient)
        checkIfUserIsAuthorize(_authorizedUser)
    {
        messages.push(
            Message(msg.sender, _recipient, _message, block.timestamp)
        );
    }

    function authorizeUserForTweet(
        address _userAddress
    )
        public
        checkIfUserDoesntExist(msg.sender)
        checkIfUserDoesntExist(_userAddress)
    {
        accessControl[msg.sender][_userAddress] = true;
    }

    function unauthorizeUserForTweet(
        address _userAddress
    )
        public
        checkIfUserDoesntExist(msg.sender)
        checkIfUserDoesntExist(_userAddress)
    {
        accessControl[msg.sender][_userAddress] = false;
    }

    function checkAuthorization(
        address _userAddress
    )
        public
        view
        checkIfUserDoesntExist(msg.sender)
        checkIfUserDoesntExist(_userAddress)
        returns (bool)
    {
        return accessControl[msg.sender][_userAddress];
    }
}
