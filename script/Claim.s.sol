// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";

contract ClaimScript is Script {
    function run() external {
        address deployedContract = vm.envAddress("AGENT_CONTRACT");
        Agent agent = Agent(deployedContract);

        uint agentId = 0;

        address caller = agent.getLatestRunOwner(agentId);
        console.log("Agent owner: ", caller);

        vm.startBroadcast(caller);
        agent.claim(agentId);
        vm.stopBroadcast();
    }
}
