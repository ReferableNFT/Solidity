// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC_rNFT.sol";

contract ERC_rNFT is ERC721, IERC_rNFT {

    struct Relationship {
        uint256[] referring;   // referring list
        uint256[] referred; // referred list
        uint256 createdTimestamp; // unix timestamp when the rNFT is being created
    }

    mapping (uint256 => Relationship) internal _relationship;
    address contractOwner = address(0);

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        contractOwner = msg.sender;
    }

    function safeMint(uint256 tokenId, uint256[] memory _tokenIds) public {
        _safeMint(msg.sender, tokenId);
        setNode(tokenId, _tokenIds);
    }

    /// @notice set the referring list of an rNFT
    /// Throws if `tokenId` is not a valid rNFT
    /// @param _tokenIds array of rNFTs, recommended to check duplication at the caller's end
    function setNodeReferring(uint256 tokenId, uint256[] memory _tokenIds) private {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC_5521: transfer caller is not owner nor approved");
        if (contractOwner != msg.sender && _tokenIds.length == 0) { revert("ERC_5521: the referring list cannot be empty"); }

        Relationship storage relationship = _relationship[tokenId];
        relationship.referring = _tokenIds;
        relationship.createdTimestamp = block.timestamp;
        emit UpdateNode(tokenId, msg.sender, relationship.referring, relationship.referred);
    }

    /// @notice set the referred list of an rNFT
    /// Throws if `tokenId` is not a valid rNFT
    /// @param _tokenIds array of rNFTs, recommended to check duplication at the caller's end
    function setNodeReferred(uint256 tokenId, uint256[] memory _tokenIds) private {
        for (uint i = 0; i < _tokenIds.length; i++) {
            Relationship storage relationship = _relationship[_tokenIds[i]];

            require(tokenId != _tokenIds[i], "ERC_5521: self-reference not allowed");
            if (relationship.createdTimestamp >= block.timestamp) { revert("ERC_5521: the referred rNFT needs to be a predecessor"); } // Make sure the reference complies with the timing sequence

            relationship.referred.push(tokenId);
            emit UpdateNode(_tokenIds[i], ownerOf(_tokenIds[i]), relationship.referring, relationship.referred);
        }
    }

    /// @notice set the referred list of an rNFT and update the referring list of each one in the referred list
    /// Throws if `tokenId` is not a valid rNFT
    /// @param _tokenIds array of rNFTs, recommended to check duplication at the caller's end
    function setNode(uint256 tokenId, uint256[] memory _tokenIds) public virtual override {
        setNodeReferring(tokenId, _tokenIds);
        setNodeReferred(tokenId, _tokenIds);
    }

    /// @notice Get the referring list of an rNFT
    /// @param tokenId The considered rNFT
    /// @return The referring list of an rNFT
    function referringOf(uint256 tokenId) external view virtual override returns(uint256[] memory) {
        require(_exists(tokenId), "ERC_5521: token ID not existed");
        return _relationship[tokenId].referring;
    }

    /// @notice Get the referred list of an rNFT
    /// @param tokenId The considered rNFT
    /// @return The referred list of an rNFT
    function referredOf(uint256 tokenId) external view virtual override returns(uint256[] memory) {
        require(_exists(tokenId), "ERC_5521: token ID not existed");
        return _relationship[tokenId].referred;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC_rNFT).interfaceId || super.supportsInterface(interfaceId);
    }
}