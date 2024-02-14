//SPDX-License-Identifier: MIT

// deploy mocks when we are on the anvil chain
// keep track of the contract adddress of differernt chains
// sepolia nd ethereum mainet
// here what we want is the price feed address -> which is different for diff networks..
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // we are using struct, so as to enable to use other parameters apart from price feed, like vrf address, gas price etc.,
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    // u can see the cheat sheet in the solidity docs .. which mentions about the block.chainid. remember i is not capital letter
    // u can get the chailink id for a network in chainlist.org
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        // here as there is only element in the struct, we may use directly:
        // NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306)
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=6
    // also to get the api key for the mainnet, use alchemy create app, give the name and then go for the api key , inside copy the address of https:..and use it in the .env
    // THEN DO SOURCE .ENV AND LATER , EVEN FOR THE MAIN NET DO THE FORK URL TEST
    // that is forge test --fork-url $MAINNET_RPC_URL -> THE TESTS SHD GO RIGHT
    // WE WONT USUSALLY DO TO THE MAINNET, WE DO TO SOME L2 LIKE - ARBITRUM, ..
    //NOW FOR THE ANVIL CONFIG, AS THERE ARE NO CONTRACT ADDRESSES , WE HAVE TO DEPLOY A MOCK CONTRACT ..

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } // in the readme ...
        //price feed address
        // deploy the mocks and return the mock address
        // with the vm.startBroadcast we can deploy the mock contract to the local anvil chain
        // also as we arew using the vm kw, we cannot use the pure kw( as the vm.. , will modify the state) in the current function
        // additionally the helper config contract shd have the is Script to have access to the vm kw
        vm.startBroadcast();
        // in between we deploy our own price feed, for which we need a pricefeed contract.. for tghis , in our test folder -> new folder-> mocks, where we put all of our contracts taht we need for the testing
        // though mocks has contract , but we put it separate from our core code base in the src folder
        // we already have such one in the lib folder -> chainlink-brownie-contracts , but it is in older version.
        // so, github of foundry-fundme-> test folder-> in the MockV3Aggregator.sol, u have the contract written( though not explicitly mentioned as mock ), JUST COPY IT
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        // Here in order to avoid the magic numbers, that is to write the no.s as args and we have to go back to the documentation to find what thgose are, we choose to initialise and declare them and use the names in the args..
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
// NOW DO forge test - > if it passes it ,means we got a network agnostic set up..
