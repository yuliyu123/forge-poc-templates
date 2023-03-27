pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../pocs/MetaViceHack.sol";

contract MetaViceHackTest is Test {
    uint256 mainnetFork;
    MetaViceHack public metaViceHack;

    function setUp() public {
        mainnetFork = vm.createFork("eth");
        vm.selectFork(mainnetFork);

        metaViceHack = new MetaViceHack();
    }

    function testFlashLoan() public {
        metaViceHack.initiateAttack();
    }
}
