// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract SystemProgram {
    function create_account(bytes32 owner, uint64 len, address user, bytes32 salt) public {}
    function allocate(bytes32 acc, uint64 space) public {}
    function assign(bytes32 acc, bytes32 owner) public {}
    function transfer_(bytes32 to, uint64 amount) public {}
}
