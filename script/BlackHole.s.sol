// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {BlackHole} from "../src/BlackHole.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {AddConsumer, CreateSubscription, FundSubscription} from "./Interactions.s.sol";

contract BlackHoleScript is Script {
    BlackHole hole;
    HelperConfig config;

    function run() public returns(BlackHole, HelperConfig){
        config = new HelperConfig();

        AddConsumer addConsumer = new AddConsumer();
        (
            uint64 subscriptionId,
            bytes32 gasLane,
            uint32 callbackGasLimit,
            address vrfCoordinatorV2,
            address link,
            uint256 deployerKey,
            address owner
        ) = config.activeNetworkConfig();

		if (subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinatorV2,
                deployerKey
            );

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinatorV2,
                subscriptionId,
                link,
                deployerKey
            );
        }

		vm.startBroadcast();
        hole = new BlackHole(
            vrfCoordinatorV2,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            owner
        );
        vm.stopBroadcast();
        
        if (subscriptionId == 1) {
            // We already have a broadcast in here
            addConsumer.addConsumer(
                address(hole),
                vrfCoordinatorV2,
                subscriptionId,
                deployerKey
            );
            return (hole, config);
        }
        return (hole, config);
    }
}
