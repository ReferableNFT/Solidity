// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC_rNFT {

    // Logged when a node in the rNFT gets referred and changed
    /// @notice Emitted when the `node` (i.e., an rNFT) is changed
    event UpdateNode(uint256 indexed tokenId, address indexed owner, uint256[] _referringList, uint256[] _referredList);

    /// @notice Set the referred and referring relationship of an rNFT
    /// Throws if `tokenId` is not valid rNFT
    /// @param _tokenIds The list of the rNFTs that `tokenId` refers to
    function setNode(uint256 tokenId, uint256[] memory _tokenIds) external;

    /// @notice Get the list of the rNFTs that `tokenId` refers to
    /// Throws if `tokenId` is not valid rNFT
    /// @param tokenId The rNFT of the referring list
    function referringOf(uint256 tokenId) external view returns(uint256[] memory);

    /// @notice Get the list of the rNFT that refers to `tokenId`
    /// Throws if `tokenId` is not valid rNFT
    /// @param tokenId The rNFT of the referred list
    function referredOf(uint256 tokenId) external view returns(uint256[] memory);
}