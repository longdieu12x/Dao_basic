// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IWhitelist {
    function isWhiteList(address) external view returns (bool);
}
