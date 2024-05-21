// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";

contract AgentCallScript is Script {
    function run() external {
        uint256 caller = vm.envUint("PRIVATE_KEY_GALADRIEL");
        vm.startBroadcast(caller);

        address deployedContract = vm.envAddress("AGENT_CONTRACT");
        Agent agent = Agent(deployedContract);
        string memory query = "What is the capital of China?";
        uint currentId = agent.runAgent(query);
        console.log("Agent run with id: ", currentId);

        // Wait for at least 2 block
        uint256 currentBlock = block.number;
        uint256 targetBlock = currentBlock + 2;
        while (block.number < targetBlock) {
            vm.roll(targetBlock);
        }

        string[] memory messages = agent.getMessageHistoryContents(currentId);

        for (uint i = 0; i < messages.length; i++) {
            console.log(messages[i]);
        }

        vm.stopBroadcast();
    }
}
