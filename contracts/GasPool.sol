// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/**
 * The purpose of this contract is to hold FURUSD tokens for gas compensation:
 * When a borrower opens a trove, an additional 50 FURUSD debt is issued,
 * and 50 FURUSD is minted and sent to this contract.
 * When a borrower closes their active trove, this gas compensation is refunded:
 * 50 FURUSD is burned from the this contract's balance, and the corresponding
 * 50 FURUSD debt on the trove is cancelled.
 */
contract GasPool {
    // do nothing, as the core contracts have permission to send to and burn from this address
}
