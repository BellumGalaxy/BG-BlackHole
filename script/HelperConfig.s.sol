//License SPX-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2Mock} from "../test/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script{
	NetworkConfig public activeNetworkConfig;

	struct NetworkConfig {
        uint64 subscriptionId;
        bytes32 gasLane;
        uint32 callbackGasLimit;
        address vrfCoordinatorV2;
        address link;
        uint256 deployerKey;
        address publicKey;
	}

    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    event HelperConfig__CreatedMockVRFCoordinator(address vrfCoordinator);

	constructor(){
		if(block.chainid == 11155111){
			activeNetworkConfig = getSepoliaVRFConfig();
		} else{
			activeNetworkConfig = getOuCreateAnvilVRFConfig();
	    }
    }

	function getSepoliaVRFConfig() public pure returns(NetworkConfig memory sepoliaConfig){
		sepoliaConfig = NetworkConfig({
            subscriptionId: 5413, // If left as 0, our scripts will create one!
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            callbackGasLimit: 300000,
            vrfCoordinatorV2: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            deployerKey: 0,
            publicKey: 0xdDBEA05dFfB7eB78924c20288BaF8C029781B13D
        });
	}

	function getOuCreateAnvilVRFConfig() public returns(NetworkConfig memory anvilConfig){
		
		if(activeNetworkConfig.vrfCoordinatorV2 != address(0)){
			return activeNetworkConfig;
		}

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast(DEFAULT_ANVIL_PRIVATE_KEY);
        VRFCoordinatorV2Mock vrfCoordinatorV2Mock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );

        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        emit HelperConfig__CreatedMockVRFCoordinator(
            address(vrfCoordinatorV2Mock)
        );

        anvilConfig = NetworkConfig({
            subscriptionId: 0, // If left as 0, our scripts will create one!
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // doesn't really matter
            callbackGasLimit: 300_000, // 300,000 gas
            vrfCoordinatorV2: address(vrfCoordinatorV2Mock),
            link: address(link),
            deployerKey: DEFAULT_ANVIL_PRIVATE_KEY,
            publicKey: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        });
	}
}