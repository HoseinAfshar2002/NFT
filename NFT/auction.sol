// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/interfaces/IERC721.sol";

contract Auction {
    event Strat();
    event Bid(address indexed sender, uint price);
    event Withraw(address indexed bidder, uint price);
    event End(address winner, uint price);

    IERC721 public nft;
    uint public nftId;
    address payable public seller;
    uint endAt;
    bool public started;
    bool public ended;
    address public highOrderAddress;
    uint public highOrder;
    mapping(address => uint) public orders;

    constructor(address _nft, uint _nftId, uint _startedorders) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highOrder = _startedorders;
    }

    function strat() external {
        require(!started, "already start....");
        require(msg.sender == seller, "not seller");
        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = block.timestamp + 1 days;
        emit Strat();
    }

    function order() external payable {
        require(started, "not started");
        require(block.timestamp < endAt);
        require(msg.value > highOrder);
        if (highOrderAddress != address(0)) {
            orders[highOrderAddress] += highOrder;
        }
        highOrderAddress = msg.sender;
        highOrder = msg.value;
        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint balance = orders[msg.sender];
        orders[msg.sender] = 0;
        payable(msg.sender).transfer(balance);
        emit Withraw(msg.sender, balance);
    }

    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");
        ended = true;
        if (highOrderAddress != address(0)) {
            nft.safeTransferFrom(address(this), highOrderAddress, nftId);
            seller.transfer(highOrder);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }
        emit End(highOrderAddress, highOrder);
    }
}
