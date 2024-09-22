// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ClothingNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    // Optimisation : Structure allégée avec ID numérique pour le QR code
    struct ClothingItem {
        string name;
        uint256 creationDate;
        uint256 qrCodeHash;  // Remplacer qrCodeUrl par un hash ou un identifiant numérique pour limiter les chaînes
        address currentOwner;
    }

    mapping(uint256 => ClothingItem) public clothingItems;

    event NFTCreated(uint256 indexed tokenId, string name, uint256 qrCodeHash);
    event NFTTransferred(uint256 indexed tokenId, address from, address to);

    constructor() ERC721("ClothingNFT", "CLOTH") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function createNFT(string memory name, uint256 qrCodeHash) public onlyOwner {
        uint256 tokenId = tokenCounter;
        
        // Limiter les accès au storage pour économiser du gas
        clothingItems[tokenId] = ClothingItem(name, block.timestamp, qrCodeHash, msg.sender);
        _mint(msg.sender, tokenId);

        emit NFTCreated(tokenId, name, qrCodeHash); // Utiliser les événements pour enregistrer l'historique
        tokenCounter++;
    }

    function transferNFT(address to, uint256 tokenId) public {
        require(to != address(0), "Invalid recipient address");
        require(ownerOf(tokenId) == msg.sender, "You do not own this token");

        // Transfert unique et mise à jour
        _transfer(msg.sender, to, tokenId);
        clothingItems[tokenId].currentOwner = to; // Stocker le nouveau propriétaire

        emit NFTTransferred(tokenId, msg.sender, to); // Enregistrer via un événement
    }

    function burnNFT(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You do not own this token");
        
        _burn(tokenId);
        delete clothingItems[tokenId]; // Supprimer les données associées

        // Pas besoin de traquer _tokenExists car l'appel à _burn le gère
    }

    function getNFTInfo(uint256 tokenId) public view returns (string memory, uint256, uint256, address) {
        ClothingItem memory item = clothingItems[tokenId];
        return (item.name, item.creationDate, item.qrCodeHash, item.currentOwner);
    }
}
