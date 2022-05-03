// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";

contract WhiteList {
    using Counters for Counters.Counter;
    address private immutable owner;
    mapping(uint256 => address) public whiteList;
    mapping(address => bool) public isWhiteList;
    uint256 public maximumWL;
    Counters.Counter private currentWL;
    Counters.Counter private idxWhiteList;

    constructor(uint256 _maximumWL) {
        owner = msg.sender;
        maximumWL = _maximumWL;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function getCurrentWl() public view returns (uint256) {
        return currentWL.current();
    }

    function addWhitelist(address account) public onlyOwner {
        require(!isWhiteList[account], "Have been whitelist");
        require(currentWL.current() < maximumWL, "Max whitelist");
        currentWL.increment();
        idxWhiteList.increment();
        whiteList[idxWhiteList.current()] = account;
        isWhiteList[account] = true;
    }

    function removeFromWhiteList(address account) public onlyOwner {
        require(isWhiteList[account], "Haven't been whitelist");
        currentWL.decrement();
        isWhiteList[account] = false;
    }
}
