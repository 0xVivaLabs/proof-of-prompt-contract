// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";

contract AgentCheckScript is Script {
    function run() external {
        address deployedContract = vm.envAddress("AGENT_CONTRACT");
        Agent agent = Agent(deployedContract);

        uint agentId = 2;

        string[] memory messages = agent.getMessageHistoryContents(agentId);

        console.log(messages[messages.length - 1]); // last message
    }
}
