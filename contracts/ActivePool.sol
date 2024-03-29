// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "./abstracts/BaseContract.sol";
import './Interfaces/IActivePool.sol';
import "./Dependencies/CheckContract.sol";

/*
 * The Active Pool holds the FURFI collateral and FURUSD debt (but not FURUSD tokens) for all active troves.
 *
 * When a trove is liquidated, it's FURFI and FURUSD debt are transferred from the Active Pool, to either the
 * Stability Pool, the Default Pool, or both, depending on the liquidation conditions.
 *
 */
contract ActivePool is BaseContract, CheckContract, IActivePool {

    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function initialize() public initializer {
        __BaseContract_init();
    }

    string constant public NAME = "ActivePool";

    address public borrowerOperationsAddress;
    address public troveManagerAddress;
    address public stabilityPoolAddress;
    address public defaultPoolAddress;
    address public furFiAddress;
    uint256 internal FURUSDDebt;

    IERC20Upgradeable furFiToken;


    // --- Events ---
    event ActivePoolFURUSDDebtUpdated(uint _FURUSDDebt);
    event ActivePoolFURFIBalanceUpdated(uint _FURFI);
    event FURFISent(address _to, uint _amount);

    // --- Contract setters ---

    function setAddresses(
        address _borrowerOperationsAddress,
        address _troveManagerAddress,
        address _stabilityPoolAddress,
        address _defaultPoolAddress,
        address _furFiAddress
    )
        external
        onlyOwner
    {
        checkContract(_borrowerOperationsAddress);
        checkContract(_troveManagerAddress);
        checkContract(_stabilityPoolAddress);
        checkContract(_defaultPoolAddress);
        checkContract(_furFiAddress);

        borrowerOperationsAddress = _borrowerOperationsAddress;
        troveManagerAddress = _troveManagerAddress;
        stabilityPoolAddress = _stabilityPoolAddress;
        defaultPoolAddress = _defaultPoolAddress;
        furFiAddress = _furFiAddress;

        furFiToken = IERC20Upgradeable(_furFiAddress);

    }

    // --- Getters for public variables. Required by IPool interface ---

    function getFURFI() public view override returns (uint) {
        return furFiToken.balanceOf(address(this));
    }

    function getFURUSDDebt() external view override returns (uint) {
        return FURUSDDebt;
    }

    // --- Pool functionality ---

    function sendFURFI(address _account, uint _amount) external override {
        _requireCallerIsBOorTroveMorSP();
        furFiToken.safeTransfer(_account, _amount);
        
        uint256 FURFI = getFURFI();
        emit ActivePoolFURFIBalanceUpdated(FURFI);
        emit FURFISent(_account, _amount);
    }

    function increaseFURUSDDebt(uint _amount) external override {
        _requireCallerIsBOorTroveM();
        FURUSDDebt  = FURUSDDebt.add(_amount);
        emit ActivePoolFURUSDDebtUpdated(FURUSDDebt);
    }

    function decreaseFURUSDDebt(uint _amount) external override {
        _requireCallerIsBOorTroveMorSP();
        FURUSDDebt = FURUSDDebt.sub(_amount);
        emit ActivePoolFURUSDDebtUpdated(FURUSDDebt);
    }

    // --- 'require' functions ---

    function _requireCallerIsBorrowerOperationsOrDefaultPool() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == defaultPoolAddress,
            "ActivePool: Caller is neither BO nor Default Pool");
    }

    function _requireCallerIsBOorTroveMorSP() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress ||
            msg.sender == stabilityPoolAddress,
            "ActivePool: Caller is neither BorrowerOperations nor TroveManager nor StabilityPool");
    }

    function _requireCallerIsBOorTroveM() internal view {
        require(
            msg.sender == borrowerOperationsAddress ||
            msg.sender == troveManagerAddress,
            "ActivePool: Caller is neither BorrowerOperations nor TroveManager");
    }

}