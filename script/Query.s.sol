// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";
import "../src/ChatOracle.sol";

contract QueryScript is Script {
    function run() external {
        uint256 caller = vm.envUint("PRIVATE_KEY");
        address deployedContract = vm.envAddress("AGENT_CONTRACT");

        vm.startBroadcast(caller);
        Agent agent = Agent(deployedContract);
        string memory query = "If u were a Python compiler, what's the output of print('PoP')? Just show result";
        uint currentId = agent.runAgent(query);
        console.log("Agent run with id: ", currentId);

        vm.stopBroadcast();
    }
}
