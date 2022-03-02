//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/// @title Keep track of each token using the Counter lib and mint new NFTs.
/// @notice conforms to ERC721URIStorage protocol to allow storing metadata on-chain.
/// @dev no access control is implemented. This contract is only used for zku's assignments.
contract PizzaSlice is ERC721URIStorage {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // an array representation of the Merkle tree
    bytes32[] public leaves;

    // unique token ids are needed to make tokens non-fungible
    Counters.Counter private _tokenIds;

    /// @notice initiates this contract inherited from the ERC721 interface
    constructor() ERC721("PizzaSlice", "SLICE") {}

    /// @notice creates a new NFT to a designated address
    /// @param user the address of an account
    /// @return the id of the newly minted NFT
    function mintTo(address user) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "PizzaSlice #',
            newItemId.toString(),
            '"',
            '"description": "A slice of the finest New York dollar pizza!"'
            "}"
        );
        string memory tokenURI = string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );

        _mint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);
        _commitToTree(msg.sender, user, newItemId, tokenURI);
        return newItemId;
    }

    ///@notice an internal function used to update the Merkle Tree upon each minting action
    ///@param sender the address of msg.sender
    ///@param receiver the address of the recipient of the newly minted NFT
    ///@param tokenId the id of the newly minted NFT
    ///@param tokenURI a base64 encoded string represetation of the newly minted NFT's metadata
    function _commitToTree(
        address sender,
        address receiver,
        uint256 tokenId,
        string memory tokenURI
    ) internal {
        // If we are doing a first-time commit, we should just use its hash value as the root of the tree
        if (leaves.length == 0) {
            leaves.push(
                keccak256(abi.encodePacked(sender, receiver, tokenId, tokenURI))
            );
            return;
        }
        // otherwise, we simply append the new hash value to the `leaves` array, then compute and append the root of the tree
        else {
            leaves.push(
                keccak256(abi.encodePacked(sender, receiver, tokenId, tokenURI))
            );
            leaves.push(
                keccak256(
                    abi.encodePacked(
                        leaves[leaves.length - 1],
                        leaves[leaves.length - 2]
                    )
                )
            );
        }
    }
}
