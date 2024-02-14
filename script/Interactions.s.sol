// SPDX-License-Identifier:MIT
// this is to enable interactions with the code .. also here we need the most recently deployed contract -> for this the foundry-devops helps
//it keeps the track of most recently deployed version of the contract..
//forge install ChainAccelOrg/foundry-devops --no-commit
// but this keeps changing and u can see the new one at Cyfrin/foundry-devopse latest info...
// currently the video mentioned is not working so, i have used the cyfrin/foundry-devops to get th
//Fund -
//Withdraw
pragma solidity ^0.8.19;
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol"; // this u can do after installing the package using the above command
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();

        console.log(" funded fund me with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();

        // here we have our run function call the fundfundme function
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );

        withdrawFundMe(mostRecentlyDeployed);
    }
}
