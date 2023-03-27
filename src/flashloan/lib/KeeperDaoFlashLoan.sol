pragma solidity ^0.8.0;

import "forge-std/interfaces/IERC20.sol";
import "forge-std/console.sol";


library KeeperDaoFlashLoan {
    /**
     * @dev struct that hold the reference of Euler and the dToken
     */
    struct Context {
        IKeepDao dToken;
    }

    // https://github.com/yueying007/blockchainclass/blob/master/lesson6/Contract/SimpleArbi.sol
    bytes4 constant CALLBACK_SELECTOR = 0x317b9863; // keccak256(receiveLoan(bytes))

    function takeFlashLoan(address token, uint256 amount) internal {
        Context memory context = context(token);
        context.dToken.borrow(token, amount, abi.encodeWithSignature("receiveLoan(bytes)", abi.encode(token, amount)));
    }

    // WETH vault 
    address constant liquidityPool = 0x4F868C1aa37fCf307ab38D215382e88FCA6275E2;

    function payFlashLoan(bytes calldata data) internal {
        (address token, uint256 amount) = unpackData(data);
        Context memory context = context(token);

        // require(msg.sender == 0x17a4C8F43cB407dD21f9885c5289E66E21bEcD9D, "KeepDaoFlashloan: Callback msg.sender was not Euler");

        IERC20(token).transfer(liquidityPool, amount);
    }

    function unpackData(bytes calldata data) internal pure returns (address token, uint256 amount) {
        (bytes memory params) = abi.decode(data[4:], (bytes));
        (token, amount) = abi.decode(params, (address, uint256));
        return (token, amount);
    }

    function context(address token) internal view returns (Context memory) {
        IKeepDao dToken;
        address euler;

        if (block.chainid == 1) {
            // Ethereum mainnet
            dToken = IKeepDao(liquidityPool);
        } else {
            revert("KeepDaoFlashLoan: Chain not supported");
        }

        return Context(dToken);
    }
}

interface IKeepDao {
    function borrow(address _token, uint256 _amount, bytes calldata _data) external;
}
