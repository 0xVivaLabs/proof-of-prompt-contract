// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/Agent.sol";

contract DeployScript is Script {
    function run() external {
        uint256 caller = vm.envUint("PRIVATE_KEY_GALADRIEL");
        address oracleAddress = vm.envAddress("ORACLE_ADDRESS");
        vm.startBroadcast(caller);

        Agent agent = new Agent(oracleAddress, "");
        address deployerAddress = vm.addr(caller);
        console.log("Deployer address: ", deployerAddress);
        console.log("Agent address: ", address(agent));

        vm.stopBroadcast();
    }
}
