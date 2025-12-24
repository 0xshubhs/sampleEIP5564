// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/ERC5564Registry.sol";
import "../src/ERC5564Messenger.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        // Broadcast a transaction to deploy contracts
        vm.startBroadcast();
        ERC5564Registry registry = new ERC5564Registry();
        ERC5564Messenger messenger = new ERC5564Messenger();

    // Example stealth meta-address (spending pubkey concatenated with viewing pubkey)
    // Use the same string format as tests (leading "0x"), so the contract's parse function
    // which expects a bytes input with >= 106 bytes works correctly when ABI-encoded via calldata.
    bytes memory stealthMetaAddress = bytes("0x3498B6C91680a0079E365e5C43dCa8f9e33aa4a53b39fbaa609ba4ebe0db1fee8bb9d78bdb681044ab19418dc819fbb458496b59");

        (address stealthAddress, bytes memory ephemeralPubKey, bytes1 viewTag) = messenger.generateStealthAddress(stealthMetaAddress);

        // Use console-style logging available via forge script runs (optional)
        // Note: When running as a script with `forge script`, these logs will be printed.
        // Print addresses for visibility
        console.logAddress(address(registry));
        console.logAddress(address(messenger));
        console.log("stealth address: %s", stealthAddress);

        vm.stopBroadcast();
    }
}
