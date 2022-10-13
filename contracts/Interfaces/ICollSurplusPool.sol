// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface ICollSurplusPool {

    function getFURFI() external view returns (uint);

    function getCollateral(address _account) external view returns (uint);

    function accountSurplus(address _account, uint _amount) external;

    function claimColl(address _account) external;

    function receiveFURFI(uint _amount) external;
}
