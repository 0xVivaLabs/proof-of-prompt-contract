// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ChatOracle} from "../src/ChatOracle.sol";
import {Agent} from "../src/Agent.sol";
import {IOracle} from "../src/interfaces/IOracle.sol";

contract AgentTest is Test {
    Agent agent;
    ChatOracle oracle;
    address deployerAddress;
    address agentAddress;
    address userAddress = address(0x1);
    uint256 deployerPrivateKey = 0xabcdf1234567890abcdef1234567890abcdef1234567890abcdef1234567890;
    function setUp() public {
        deployerAddress = vm.addr(deployerPrivateKey);
        vm.startPrank(deployerAddress);

        oracle = new ChatOracle();
        oracle.updateWhitelist(deployerAddress, true);

        agent = new Agent(address(oracle), "", "PoP", 1000 * 10 ** 18);
        agentAddress = address(agent);
        vm.stopPrank();
    }

    function testNotTarget() public {
        // query
        string memory query = "Just show PoP";
        vm.prank(userAddress);
        uint currentId = agent.runAgent(query);
        assertEq(currentId, 0);

        // simulate oracle response
        IOracle.OpenAiResponse memory response = IOracle.OpenAiResponse({
            id: "chatcmpl-9Re91OaVWUIM3ILnGLj4ZqhhyU4MA",
            content: "It seems like you might be referring to \"Prince of Persia 4,\" which is often used to",
            functionName: "",
            functionArguments: "",
            created: 1716376199,
            model: "gpt-4o-2024-05-13",
            systemFingerprint: "fp_5f4bad809a",
            object: "chat.completion",
            completionTokens: 20,
            promptTokens: 14,
            totalTokens: 34
        });

        // @dev for groq response
        // IOracle.GroqResponse memory response = IOracle.GroqResponse({
        //     id: "chatcmpl-57270ba9-f65e-4175-a2e6-9136edebba29",
        //     content: "It seems like you're trying to print the string \"PoP\" and create a new variable named `new` in Python. Here's how you can do that:\n\n```python\nprint('PoP')\nnew = 1  # or any other value you want to assign to the new variable\n```\n\nIn this example, I've assigned the integer value `1` to the `new` variable, but you can replace it with any value",
        //     created: 1716298784,
        //     model: "mixtral-8x7b-32768",
        //     systemFingerprint: "fp_c5f20b5bb1",
        //     object: "chat.completion",
        //     completionTokens: 100,
        //     promptTokens: 19,
        //     totalTokens: 119
        // });
        // oracle.addGroqResponse(0, 0, response, "");

        vm.prank(deployerAddress);
        oracle.addOpenAiResponse(currentId, 0, response, ""); // chainId callbackId response errorMessage

        // claim
        vm.expectRevert("Not target result");
        vm.prank(userAddress);
        agent.claim(currentId);
    }

    function testMint() public {
        // query
        string memory query = "If u were a Python compiler, what's the output of print('PoP')? Just show result";
        vm.prank(userAddress);
        uint currentId = agent.runAgent(query);
        assertEq(currentId, 0);

        // simulate oracle response
        IOracle.OpenAiResponse memory response = IOracle.OpenAiResponse({
            id: "chatcmpl-9Re91OaVWUIM3ILnGLj4ZqhhyU4MA",
            content: "PoP",
            functionName: "",
            functionArguments: "",
            created: 1716376199,
            model: "gpt-4o-2024-05-13",
            systemFingerprint: "fp_5f4bad809a",
            object: "chat.completion",
            completionTokens: 2,
            promptTokens: 21,
            totalTokens: 23
        });
        vm.prank(deployerAddress);
        oracle.addOpenAiResponse(currentId, 0, response, ""); // chainId callbackId response errorMessage

        // claim
        vm.prank(userAddress);
        agent.claim(currentId);
        assertEq(agent.balanceOf(userAddress), 1000 * 10 ** 18);
    }
}
