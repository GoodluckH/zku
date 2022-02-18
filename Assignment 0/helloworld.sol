// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/// @title An example contract
/// @author Xipu Li
/// @notice A hello-world example contract for zku background assignment 
/// @dev An efficient way to get the uint variable is simply to declare it as public
contract HelloWorld {
    uint myInt;

    /// @notice Get the state variable myInt
    /// @return unsigned 256-bit integer myInt
    function retrieveInteger() external view returns (uint) {
        return myInt;
    }
}
