// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";


/**
 * @title  The data to be stored on the Deposit Certificate
 */
struct DepositData {
    uint256 nominal;        // nominal value of the deposit (based on token)
    uint32  timestamp;      // timestamp when the deposit was created
    bool    hasBonus;       // bonus flag for the vault accounting
}

/**
 * @author  PRC
 * @title   Kratos-X Deposit Certificate NFT Smart Contract
 */
interface IKratosXDeposit is IERC721, IERC721Enumerable, IERC721Metadata {
    /// The underlying token used for this contract
    function underlyingToken() external returns (IERC20);

    /// The deposit internal data
    function depositData(uint256 tokenId) external returns (DepositData memory);

    /**
     * @notice  This function mints a new deposit cerificate
     * @dev     Call this function to mint a new deposit certificate
     * @param   to      The address of the depositer (soul bound)
     * @param   data    The deposit internal data
     * @return  tokenId The token id minted
     */
    function mint(address to, DepositData calldata data) external returns (uint256 tokenId);

    /**
     * @notice  This function burns a deposit certificate
     * @dev     Call this function to burn a deposit certificate
     * @param   tokenId     The deposit certificate token id to burn
     */
    function burn(uint256 tokenId) external;

}