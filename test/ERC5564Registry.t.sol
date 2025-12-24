// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/ERC5564Registry.sol";

contract ERC5564RegistryTest is Test {
    ERC5564Registry registry;

    function setUp() public {
        registry = new ERC5564Registry();
    }

    function testRegisterKeysStoresValue() public {
        uint256 scheme = 1;
        bytes memory meta = "0x11223344";

        // expect the mapping to be empty initially
        bytes memory initially = registry.stealthMetaAddressOf(abi.encode(address(this)), scheme);
        assertEq(initially.length, 0);

        // call registerKeys
        vm.prank(address(this));
        registry.registerKeys(scheme, meta);

        // read back
        bytes memory stored = registry.stealthMetaAddressOf(abi.encode(address(this)), scheme);
        assertEq(stored, meta);
    }
}
