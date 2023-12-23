// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import {DepositData} from "./IKratosXDeposit.sol";


/**
 * @author  PRC
 * @title   Kratos-X Deposit Certificate NFT Smart Contract
 */
contract KratosXDeposit is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    error InvalidAddress();
    error SoulBoundToken();

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    uint256 private nextTokenId;    // the next token id to mint

    IERC20 public immutable underlyingToken;    // the underlying token used for this contract

    mapping (uint256 tokenId => DepositData) public depositData;

    /**
     * @notice  Constructor
     * @param   token       Underlying token of the deposit certificates
     * @param   admin       Initial admin (owner)
     * @param   operator    Initial operator (minter/burner)
     */
    constructor(address token, address admin, address operator) ERC721("KratosXDeposit", "KXD") {
        if (token == address(0) || admin == address(0) || operator == address(0)) revert InvalidAddress();
        underlyingToken = IERC20(token);

        _grantRole(ADMIN_ROLE, admin);
        _grantRole(OPERATOR_ROLE, operator);

        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(OPERATOR_ROLE, ADMIN_ROLE);
    }

    /**
     * @notice  This function mints a new deposit cerificate
     * @dev     Call this function to mint a new deposit certificate
     * @param   to      The address of the depositer (soul bound)
     * @param   data    The deposit internal data
     * @return  tokenId The token id minted
     */
    function mint(address to, DepositData calldata data) external onlyRole(OPERATOR_ROLE) returns (uint256 tokenId) {
        tokenId = nextTokenId++;
        _safeMint(to, tokenId);
        depositData[tokenId] = data;
        _setTokenURI(tokenId, generateUri(tokenId, to, data));
    }

    /**
     * @notice  This function burns a deposit certificate
     * @dev     Call this function to burn a deposit certificate
     * @param   tokenId     The deposit certificate token id to burn
     */
    function burn(uint256 tokenId) external onlyRole(OPERATOR_ROLE) {
        delete depositData[tokenId];
        _burn(tokenId);
    }

    function generateUri(uint256 tokenId, address owner, DepositData calldata data) internal pure returns (string memory) {
        // TODO: return the correct uri from backend
        return "";
    }

    // Soulbound token

    function _update(address to, uint256 tokenId, address auth) internal override(ERC721, ERC721Enumerable) returns (address) {
        if (auth != address(0) && to != address(0)) revert SoulBoundToken();
        return super._update(to, tokenId, auth);
    }

    // Required overrides

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }
    
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}