// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./INFTMarketplace.sol";
import "./IFlameDevs.sol";

contract FlameDevsDao is Ownable {
    // Create an enum named Vote containing possible options for a vote
    enum Vote {
        YAY,
        NAY
    }

    struct Proposal {
        // nftTokenId - the tokenID of the NFT to purchase from FakeNFTMarketplace if the proposal passes
        uint256 nftTokenId;
        // deadline - the UNIX timestamp until which this proposal is active. Proposal can be executed after the deadline has been exceeded.
        uint256 deadline;
        // yayVotes - number of yay votes for this proposal
        uint256 yayVotes;
        // nayVotes - number of nay votes for this proposal
        uint256 nayVotes;
        // executed - whether or not this proposal has been executed yet. Cannot be executed before the deadline has been exceeded.
        bool executed;
        // voters - a mapping of CryptoDevsNFT tokenIDs to booleans indicating whether that NFT has already been used to cast a vote or not
        mapping(uint256 => bool) voters;
    }
    mapping(uint256 => Proposal) public proposals;
    uint256 public numProposals;
    IFlameDevs flameDevsNFT;
    INFTMarketplace nftMarketplace;
    uint256 _durationTime = 5 minutes;

    modifier isDaoMember() {
        require(
            flameDevsNFT.balanceOf(msg.sender) > 0,
            "You are not a dao member!"
        );
        _;
    }
    modifier inactiveProposalOnly(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline <= block.timestamp,
            "Deadline is not exceeded"
        );
        require(
            proposals[proposalIndex].executed == false,
            "Proposal already executed"
        );
        _;
    }
    modifier canActiveProposal(uint256 proposalIndex) {
        require(
            proposals[proposalIndex].deadline > block.timestamp,
            "Deadline exceeded"
        );
        _;
    }

    constructor(address _flameDevAddress, address _nftMarketplaceAddress)
        payable
    {
        nftMarketplace = INFTMarketplace(_nftMarketplaceAddress);
        flameDevsNFT = IFlameDevs(_flameDevAddress);
    }

    function setDurationTime(uint256 durationTime_) public onlyOwner {
        _durationTime = durationTime_;
    }

    function getDurationTime() public view returns (uint256) {
        return _durationTime;
    }

    function createProposal(uint256 _nftTokenId)
        external
        isDaoMember
        returns (uint256)
    {
        require(nftMarketplace.available(_nftTokenId), "nft not for sale");
        Proposal storage proposal = proposals[numProposals];
        proposal.nftTokenId = _nftTokenId;
        proposal.deadline = block.timestamp + _durationTime;
        numProposals++;
        return numProposals - 1;
    }

    function voteOnProposal(uint256 proposalIndex, Vote vote)
        external
        isDaoMember
        canActiveProposal(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];

        uint256 voterNFTBalance = flameDevsNFT.balanceOf(msg.sender);
        uint256 numVotes = 0;

        // Calculate how many NFTs are owned by the voter
        // that haven't already been used for voting on this proposal
        for (uint256 i = 0; i < voterNFTBalance; i++) {
            uint256 tokenId = flameDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            if (proposal.voters[tokenId] == false) {
                numVotes++;
                proposal.voters[tokenId] = true;
            }
        }
        require(numVotes > 0, "ALREADY_VOTED");

        if (vote == Vote.YAY) {
            proposal.yayVotes += numVotes;
        } else {
            proposal.nayVotes += numVotes;
        }
    }

    function executeProposal(uint256 proposalIndex)
        external
        isDaoMember
        canActiveProposal(proposalIndex)
    {
        Proposal storage proposal = proposals[proposalIndex];
        if (proposal.yayVotes > proposal.nayVotes) {
            uint256 nftPrice = nftMarketplace.getPrice();
            require(address(this).balance >= nftPrice, "not enough funds");
            nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
        }
        proposal.executed = true;
    }

    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function sendEther() public payable {
        payable(address(this)).transfer(msg.value);
    }

    receive() external payable {}

    fallback() external payable {}
}
