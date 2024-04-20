// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

import {BlackHole} from "../../src/BlackHole.sol";
import {BlackHoleScript} from "../../script/BlackHole.s.sol";

import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../mocks/VRFCoordinatorV2Mock.sol";

contract BlackHoleTest is Test {
    BlackHoleScript script;
    BlackHole hole;
    HelperConfig config;

    uint64 subscriptionId;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    address vrfCoordinatorV2;
    address link;
    address router;

    address owner = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address BARBA = makeAddr("barba");
    address RAFFA = makeAddr("raffa");
    address PUKA = makeAddr("puka");
    address ATHENA = makeAddr("athena");

    function setUp() external {
        script = new BlackHoleScript();
        (hole, config) = script.run();

        (
            subscriptionId,
            gasLane,
            callbackGasLimit,
            vrfCoordinatorV2,
            link,
            //deployerKey
            ,
            //publicKey
        ) = config.activeNetworkConfig();
    }
}
