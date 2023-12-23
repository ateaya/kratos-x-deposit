// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {KratosXDeposit} from "../src/KratosXDeposit.sol";

contract AteayaWhitelistTest is Test {
    KratosXDeposit public deposit;

    address public deployer;
    address public admin;
    address public operator;
    address public user;

    address public token;

    function setUp() public {
        string memory mnemonic = "test test test test test test test test test test test junk";
        uint256 privateKey = vm.deriveKey(mnemonic, 0);
        deployer = msg.sender;
        admin = vm.addr(privateKey);
        operator = vm.addr(privateKey + 1);
        user = vm.addr(privateKey + 2);
        token = vm.addr(privateKey + 10);

        deposit = new KratosXDeposit(token, admin, operator);
    }

    function test_InitializedCorrectly() public {
        assertEq(address(deposit.underlyingToken()), token, "invalid token");
        assertTrue(deposit.hasRole(keccak256("ADMIN_ROLE"), admin), "invalid admin");
        assertTrue(deposit.hasRole(keccak256("OPERATOR_ROLE"), operator), "invalid admin");
    }

    function test_MintDeposit() public {
        vm.prank(operator);
        deposit.mint(user, "", KratosXDeposit.Deposit(5000, uint32(block.timestamp), true));
        assertEq(deposit.balanceOf(user), 1, "user has no token");
        (uint256 nominal, uint32 timestamp, bool hasBonus) = deposit.depositData(0);
        assertEq(nominal, 5000, "wrong nominal value");
        assertEq(timestamp, block.timestamp, "wrong timestamp");
        assertEq(hasBonus, true, "wrong hasBonus flag");
    }

    function testFail_AdminCannotMint() public {
        vm.prank(admin);
        deposit.mint(user, "", KratosXDeposit.Deposit(5000, uint32(block.timestamp), true));
    }

    function testFail_RegularUserCannotMint() public {
        vm.prank(user);
        deposit.mint(user, "", KratosXDeposit.Deposit(5000, uint32(block.timestamp), true));
    }

    function test_BurnDeposit() public {
        vm.startPrank(operator);
        deposit.mint(user, "", KratosXDeposit.Deposit(5000, uint32(block.timestamp), true));
        deposit.burn(0);
        vm.stopPrank();
        assertEq(deposit.balanceOf(user), 0, "user still has a token");
        (uint256 nominal, uint32 timestamp, bool hasBonus) = deposit.depositData(0);
        assertEq(nominal, 0, "nominal value not clean");
        assertEq(timestamp, 0, "timestamp not clean");
        assertEq(hasBonus, false, "hasBonus flag not clean");
    }

    function testFail_AdminCannotBurn() public {
        vm.prank(operator);
        deposit.mint(user, "", KratosXDeposit.Deposit(5000, uint32(block.timestamp), true));
        vm.prank(admin);
        deposit.burn(0);
    }

    function testFail_RegularUserCannotBurn() public {
        vm.prank(operator);
        deposit.mint(user, "", KratosXDeposit.Deposit(5000, uint32(block.timestamp), true));
        vm.prank(user);
        deposit.burn(0);
    }

}
