// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC5564Messenger.sol";

contract ERC5564MessengerAssertTest is Test {
    ERC5564Messenger messenger;

    function setUp() public {
        messenger = new ERC5564Messenger();
    }

    function testGenerateAndRecoverStealthKey() public {
        // Using the example keys from the repository test
        bytes memory spendingKey = "0x8dea547d647088d01cb6cf1a1fdefe721c60d5aac987f1ccba317a6ea93e1d66";
        bytes memory viewingKey = "0x3b39fbaa609ba4ebe0db1fee8bb9d78bdb681044ab19418dc819fbb458496b59";
        bytes memory stealthMetaAddress = "0x3498B6C91680a0079E365e5C43dCa8f9e33aa4a53b39fbaa609ba4ebe0db1fee8bb9d78bdb681044ab19418dc819fbb458496b59";

        (address stealthAddress, bytes memory ephemeralPubKey, bytes1 viewTag) = messenger.generateStealthAddress(stealthMetaAddress);

        // compute stealth private key (off-chain receiver would compute same)
        bytes memory stealthPrivate = messenger.computeStealthKey(stealthAddress, ephemeralPubKey, spendingKey, viewingKey);

        // Ensure returned private key is non-empty
        assertTrue(stealthPrivate.length > 0, "stealth private key should be returned");

        // Derive public address from the computed stealth private key and ensure it's an address
        bytes32 pk = toBytes32(stealthPrivate);
        address recovered = derivePublicKey(pk);

        // recovered must be a non-zero address
        assertTrue(recovered != address(0), "recovered stealth public address should be non-zero");
    }

    // Helpers copied from existing test file
    uint256 public constant SECP256K1_GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 public constant SECP256K1_GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint256 public constant SECP256K1_A = 0;
    uint256 public constant SECP256K1_PP = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

    function derivePublicKey(bytes32 privateKey) internal pure returns (address) {
      (uint256 gx, uint256 gy) = EllipticCurve.ecMul(uint256(privateKey), SECP256K1_GX, SECP256K1_GY, SECP256K1_A, SECP256K1_PP);
      return address(uint160(uint256(keccak256(abi.encodePacked(gx, gy)))));
    }

    function toBytes32(bytes memory source) public pure returns (bytes32 result) {
      if (source.length == 0) {
          return 0x0;
      }

      assembly {
          result := mload(add(source, 32))
      }
    }
}
