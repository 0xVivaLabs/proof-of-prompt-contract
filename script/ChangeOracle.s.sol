// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";

contract ChangeOracle is Script {
    function run() external {
        uint256 caller = vm.envUint("PRIVATE_KEY");
        address oracleAddress = vm.envAddress("ORACLE_ADDRESS");

        address deployedContract = vm.envAddress("AGENT_CONTRACT");
        Agent agent = Agent(deployedContract);

        vm.startBroadcast(caller);
        agent.setOracleAddress(oracleAddress);
        vm.stopBroadcast();
    }
}
