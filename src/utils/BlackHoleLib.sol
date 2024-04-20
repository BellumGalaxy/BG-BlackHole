// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

library BlackHoleLib{

    ////////////
    ///Errors///
    ////////////
    error BlackHole_RequestNotFoundOrNotFulfilled(uint256 requestId);

    ////////////
    ///Events///
    ////////////
    event BlackHole_RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 randomValue);

    struct RequestStatus {
        uint256[] randomWords;
        bool exists;
        bool fulfilled;
        uint256 randomValue;
    }
}