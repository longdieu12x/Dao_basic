// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./IFlameDevs.sol";

contract FlameDevsToken is ERC20, Ownable {
    uint256 public constant tokenPrice = 0.0001 ether;
    uint256 maxTotalSupply = 10000 * 10**18;
    uint256 rewardForClaimNFT = 10 * 10**18;
    mapping(uint256 => bool) nftClaimed; // check whether this nftId is claimed
    IFlameDevs flameDevs;

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    constructor(address flameDevsAddress) ERC20("Flame Devs Tokenomic", "FDT") {
        flameDevs = IFlameDevs(flameDevsAddress);
    }

    function setFlameDevsContract(address flameDevsAddress) public onlyOwner {
        flameDevs = IFlameDevs(flameDevsAddress);
    }

    function mint(uint256 amount) public payable {
        uint256 totalAmount = amount * tokenPrice;
        require(msg.value >= totalAmount, "Not enough ether");
        require(
            totalSupply() + amount * 10**18 <= maxTotalSupply,
            "Over maximum total supply"
        );
        _mint(msg.sender, amount * 10**18);
    }

    function claim() public {
        uint256 balanceNFT = flameDevs.balanceOf(msg.sender);
        require(balanceNFT > 0, "You have no Flame Devs NFT");
        uint256 amount = 0;
        for (uint256 i = 0; i < balanceNFT; i++) {
            uint256 tokenId = flameDevs.tokenOfOwnerByIndex(msg.sender, i);
            nftClaimed[tokenId] = true;
            amount++;
        }
        require(amount > 0, "You have already claimed all the token");
        _mint(msg.sender, amount * rewardForClaimNFT);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}
