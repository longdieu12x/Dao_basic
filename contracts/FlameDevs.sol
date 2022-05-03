// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./IWhiteList.sol";

contract FlameDevs is ERC721Enumerable, Ownable {
    string private baseURI_;
    bool isPaused;
    uint256 minimumPrice = 0.000001 ether;
    uint256 tokenId_;
    IWhitelist whiteList;
    bool public presaleStarted;
    uint256 public presaleEnded;
    uint256 public maxSupply;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    modifier onlyWhenNotPaused() {
        require(!isPaused, "Contract is paused!");
        _;
    }
    modifier isInPresale() {
        require(
            presaleStarted && block.timestamp < presaleEnded,
            "You are not in presale"
        );
        _;
    }
    modifier isNotInPresale() {
        require(
            presaleStarted && block.timestamp >= presaleEnded,
            "You are in presale"
        );
        _;
    }
    modifier isInWhiteList(address account) {
        require(whiteList.isWhiteList(account), "You are not in whitelist");
        _;
    }

    constructor(
        string memory _baseURI,
        address whiteListAddress,
        uint256 _maxSupply
    ) ERC721("Flame Devs Token", "FDT") {
        baseURI_ = _baseURI;
        whiteList = IWhitelist(whiteListAddress);
        maxSupply = _maxSupply;
    }

    function setWhiteListContract(address whiteListAddress) public onlyOwner {
        whiteList = IWhitelist(whiteListAddress);
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI_ = _baseURI;
    }

    function setPaused(bool val) public onlyOwner {
        isPaused = val;
    }

    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 60 * 2; // only 2 minutes
    }

    function presaleMinted()
        public
        payable
        isInWhiteList(msg.sender)
        isInPresale
        onlyWhenNotPaused
    {
        require(tokenId_ < maxSupply, "Exceed max total supply");
        require(
            msg.value >= minimumPrice,
            "You have to send at least 0.000001 ether"
        );
        _safeMint(msg.sender, tokenId_);
        tokenId_++;
    }

    function mint() public payable onlyWhenNotPaused isNotInPresale {
        require(tokenId_ < maxSupply, "Exceed max total supply");
        require(
            msg.value >= minimumPrice,
            "You have to send at least 0.000001 ether"
        );
        _safeMint(msg.sender, tokenId_);
        tokenId_++;
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
