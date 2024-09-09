// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public myToken;
    address public defaultAdmin;
    address public pauser;
    address public minter;
    address public otherAccount;

    function setUp() public {
        // Asignar cuentas a variables
        defaultAdmin = address(this);
        pauser = address(0x2);
        minter = address(0x3);
        otherAccount = address(0x4);

        // Desplegar contrato MyToken
        myToken = new MyToken(defaultAdmin, pauser, minter);
    }

    function testAssignAdminRole() public view {
        bytes32 adminRole = myToken.DEFAULT_ADMIN_ROLE();
        bool hasRole = myToken.hasRole(adminRole, defaultAdmin);
        assertTrue(hasRole);
    }

    function testInitialSupplyToDeployer() public view {
        uint256 initialSupply = 1000000 * 10 ** 18; // Ajustar decimales
        uint256 balance = myToken.balanceOf(defaultAdmin);
        assertEq(balance, initialSupply);
    }

    function testPauseAndUnpause() public {
        vm.prank(pauser); // Actuar como 'pauser'
        myToken.pause();
        assertTrue(myToken.paused());

        vm.prank(pauser);
        myToken.unpause();
        assertFalse(myToken.paused());
    }

    function testRevertIfNonPauserTriesToPause() public {
        vm.prank(otherAccount); // Simula que otherAccount intenta pausar
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000004 is missing role 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a"
        );
        myToken.pause();
    }

    function testMintTokens() public {
        uint256 amountToMint = 500 * 10 ** 18; // Ajustar decimales
        vm.prank(minter);
        myToken.mint(otherAccount, amountToMint);

        uint256 balance = myToken.balanceOf(otherAccount);
        assertEq(balance, amountToMint);
    }

    function testRevertIfNonMinterTriesToMint() public {
        vm.prank(otherAccount); // Simula que otherAccount intenta acuñar
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000004 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
        );
        myToken.mint(otherAccount, 1000);
    }

    function testBurnTokens() public {
        uint256 amountToBurn = 100 * 10 ** 18; // Ajustar decimales

        // Asegurarse de que defaultAdmin tenga suficientes tokens
        vm.prank(minter);
        myToken.mint(defaultAdmin, amountToBurn);

        uint256 balanceBefore = myToken.balanceOf(defaultAdmin);

        vm.prank(defaultAdmin);
        myToken.burn(amountToBurn);

        uint256 balanceAfter = myToken.balanceOf(defaultAdmin);
        assertEq(balanceAfter, balanceBefore - amountToBurn);
    }
}
