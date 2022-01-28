// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking is ERC1155Holder {
    bytes4 public constant ERC1155_ERC165 = 0xd9b67a26; // ERC-165 identifier for the main token standard.
    bytes4 public constant ERC1155_ERC165_TOKENRECEIVER = 0x4e2312e0; // ERC-165 identifier for the `ERC1155TokenReceiver`
    bytes4 public constant ERC1155_ACCEPTED = 0xf23a6e61; // Return value from `onERC1155Received` call if a contract accepts receipt
    bytes4 public constant ERC1155_BATCH_ACCEPTED = 0xbc197c81; // Return value from `onERC1155BatchReceived` call if a contract accepts receipt
    IERC20 MyToken;
    IERC1155 MyNft;
    address nft;
    
    

    struct Stake {
        uint256 amount;
        uint256 startStaking;
        uint256 tokenId;
        address owner;
    }

    mapping(address => Stake) stakes;

    constructor(address _myTokenAddress, address _myNftAddress) {
        MyToken = IERC20(_myTokenAddress);
        MyNft = IERC1155(_myNftAddress);
        nft = _myNftAddress;
    }

    function reward() external {
        uint256 rate = 0;
        require(stakes[msg.sender].amount > 0, "No staked nfts found");
        require(rate > 0, "Rate cannot be 0");
        uint256 daysStaked = (block.timestamp -
            stakes[msg.sender].startStaking);

        if (daysStaked < 30) {
            rate = 5; //return 5% earning if stake is less than 30 days
        } else if (daysStaked < 180) {
            rate = 10; //return 10% earning if stake is 6 months i.e. 180 days
        } else {
            rate = 15; //return 15% earning - stake is more than six months
        }
        //send back the calculated earnings + token.
        MyToken.transfer(msg.sender, (stakes[msg.sender].amount * rate) / 100);
    }

    function onERC1155Received(
        address _nft,
        address from,
        uint256 tokenId,
        bytes calldata,
        uint256 amount
    ) public virtual returns (bytes4) {
        require(
            _nft == nft,
            "received nft address must be same as myNft address"
        );
        stakeNft(from, tokenId, amount);
        return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(
        address _nft,
        address from,
        uint256[] calldata ids,
        uint256[] calldata,
        bytes calldata,
        uint256 amount
    ) public virtual returns (bytes4) {
        require(
            _nft == nft,
            "received nft address must be same as myNft address"
        );
        for (uint256 i = 0; i < ids.length; ++i) {
            stakeNft(from, ids[i], amount);
        }
        return ERC1155_BATCH_ACCEPTED;
    }

    function supportsInterface(bytes4 interfaceID)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceID == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceID == 0x4e2312e0; // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    }

    function stakeNft(address from,uint256 tokenId,uint256 amount) internal {
        require(amount > 0, "Amount cannot be zero");
        Stake memory staker = stakes[from];

        staker.amount++;
        staker.startStaking = block.timestamp;
        staker.tokenId = tokenId;
        staker.owner = msg.sender;
    }

    function unStakeNft() public{
        uint256 rate = 0;
        require(stakes[msg.sender].amount > 0, "amount has to be more than 0"); //get staking balance for user

        MyToken.transfer(msg.sender, (stakes[msg.sender].amount * rate) / 100 + stakes[msg.sender].amount);    //transfer staked tokens back to user

        //reseting users staking balance
        stakes[msg.sender].amount = 0;

    }
}
