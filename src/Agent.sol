// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Uncomment this line to use console.log
// import "forge-std/console2.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IChatGpt.sol";
import "./interfaces/ERC20.sol";

contract Agent is ERC20 {
    string public prompt;
    string public target;

    struct ChatRun {
        address owner;
        IOracle.Message[] messages;
        uint messagesCount;
    }

    mapping(uint => ChatRun) public agentRuns;
    uint private agentRunCount;

    event AgentRunCreated(
        address indexed owner,
        uint indexed runId,
        string indexed query
    );

    address private owner;
    address public oracleAddress;

    event OracleAddressUpdated(address indexed newOracleAddress);

    // IOracle.GroqRequest private config;
    IOracle.OpenAiRequest private config;

    // mint logic fields
    uint public limit;

    mapping(bytes32 => bool) public usedQueries;
    mapping(uint => bool) public claimedRunIds;

    event claimEvent(address indexed owner, uint indexed runId);

    // ERC20 metadata
    function name() public view virtual override returns (string memory) {
        return string(abi.encodePacked("Prove Of Prompt(", target, ")"));
    }

    function symbol() public view virtual override returns (string memory) {
        return target;
    }

    constructor(
        address initialOracleAddress,
        string memory systemPrompt,
        string memory targetResult,
        uint mintLimit
    ) {
        owner = msg.sender;
        oracleAddress = initialOracleAddress;
        prompt = systemPrompt;
        target = targetResult;
        limit = mintLimit;

        // config = IOracle.GroqRequest({
        //     model: "mixtral-8x7b-32768",
        //     frequencyPenalty: 0,
        //     logitBias: "",
        //     maxTokens: 100,
        //     presencePenalty: 0,
        //     responseFormat: "",
        //     seed: 0,
        //     stop: "",
        //     temperature: 0,
        //     topP: 100,
        //     user: ""
        // });

        config = IOracle.OpenAiRequest({
            model: "gpt-4o",
            frequencyPenalty: 21, // > 20 for null
            logitBias: "", // empty str for null
            maxTokens: 20, // 0 for null
            presencePenalty: 21, // > 20 for null
            responseFormat: '{"type":"text"}',
            seed: 0, // null
            stop: "", // null
            temperature: 1, // Example temperature (scaled up, 10 means 1.0), > 20 means null
            topP: 101, // Percentage 0-100, > 100 means null
            tools: "",
            toolChoice: "", // "none" or "auto"
            user: "" // null
        });
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Caller is not oracle");
        _;
    }

    function setOracleAddress(address newOracleAddress) public onlyOwner {
        require(msg.sender == owner, "Caller is not the owner");
        oracleAddress = newOracleAddress;
        emit OracleAddressUpdated(newOracleAddress);
    }

    function runAgent(string memory query) public returns (uint i) {
        bytes32 queryHash = keccak256(abi.encodePacked(query));
        require(!usedQueries[queryHash], "Query used");
        usedQueries[queryHash] = true;

        ChatRun storage run = agentRuns[agentRunCount];

        run.owner = msg.sender;

        IOracle.Message memory newMessage = IOracle.Message({
            role: "user",
            content: new IOracle.Content[](1)
        });
        newMessage.content[0] = IOracle.Content({
            contentType: "text",
            value: query
        });
        run.messages.push(newMessage);
        run.messagesCount = 1;

        uint currentId = agentRunCount;
        agentRunCount = agentRunCount + 1;

        // IOracle(oracleAddress).createGroqLlmCall(currentId, config);
        // IOracle(oracleAddress).createLlmCall(currentId);
        IOracle(oracleAddress).createOpenAiLlmCall(currentId, config);
        emit AgentRunCreated(run.owner, currentId, query);

        return currentId;
    }

    function claim(uint runId) public {
        IOracle.Content memory lastResponse = getLatestMessageContent(runId);
        address lastOwner = getLatestRunOwner(runId);
        require(lastOwner == msg.sender, "Not owner");
        require(compareStrings(lastResponse.value, target), "Not target result");
        require(!claimedRunIds[runId], "Already claimed");
        claimedRunIds[runId] = true;
        _mint(msg.sender, limit);
        emit claimEvent(msg.sender, runId);
    }

    // function onOracleGroqLlmResponse(
    //     uint runId,
    //     IOracle.GroqResponse memory response,
    //     string memory /*errorMessage*/
    // ) public onlyOracle {
    //     ChatRun storage run = agentRuns[runId];

    //     require(
    //         keccak256(
    //             abi.encodePacked(run.messages[run.messagesCount - 1].role)
    //         ) == keccak256(abi.encodePacked("user")),
    //         "No message to respond to"
    //     );
    //     Message memory newMessage;
    //     newMessage.content = response.content;
    //     newMessage.role = "assistant";
    //     run.messages.push(newMessage);
    //     run.messagesCount++;
    // }

    // function onOracleLlmResponse(
    //     uint runId,
    //     string memory content,
    //     string memory /*errorMessage*/
    // ) public onlyOracle {
    //     ChatRun storage run = agentRuns[runId];

    //     require(
    //         keccak256(
    //             abi.encodePacked(run.messages[run.messagesCount - 1].role)
    //         ) == keccak256(abi.encodePacked("user")),
    //         "No message to respond to"
    //     );
    //     Message memory newMessage;
    //     newMessage.content = content;
    //     newMessage.role = "assistant";
    //     run.messages.push(newMessage);
    //     run.messagesCount++;
    // }

    function onOracleOpenAiLlmResponse(
        uint runId,
        IOracle.OpenAiResponse memory response,
        string memory errorMessage
    ) public onlyOracle {
        ChatRun storage run = agentRuns[runId];

        require(
            keccak256(
                abi.encodePacked(run.messages[run.messagesCount - 1].role)
            ) == keccak256(abi.encodePacked("user")),
            "No message to respond to"
        );

        if (!compareStrings(errorMessage, "")) {
            IOracle.Message memory newMessage = IOracle.Message({
                role: "assistant",
                content: new IOracle.Content[](1)
            });
            newMessage.content[0].contentType = "text";
            newMessage.content[0].value = errorMessage;
            run.messages.push(newMessage);
            run.messagesCount++;
        } else {
            IOracle.Message memory newMessage = IOracle.Message({
                role: "assistant",
                content: new IOracle.Content[](1)
            });
            newMessage.content[0].contentType = "text";
            newMessage.content[0].value = response.content;
            run.messages.push(newMessage);
            run.messagesCount++;
        }
    }

    function getLatestMessageContent(
        uint agentId
    ) public view returns (IOracle.Content memory) {
        return
            agentRuns[agentId].messages[agentRuns[agentId].messagesCount - 1]
                .content[0];
    }

    function getMessageHistory(
        uint chatId
    ) public view returns (IOracle.Message[] memory) {
        return agentRuns[chatId].messages;
    }

    // function getMessageHistoryContents(
    //     uint chatId
    // ) public view returns (IOracle.Message[] memory) {
    //     return agentRuns[chatId].messages;   
    // }

    // function getMessageHistoryRoles(
    //     uint chatId
    // ) public view returns (string[] memory) {
    //     string[] memory roles = new string[](agentRuns[chatId].messages.length);
    //     for (uint i = 0; i < agentRuns[chatId].messages.length; i++) {
    //         roles[i] = agentRuns[chatId].messages[i].role;
    //     }
    //     return roles;
    // }

    function getLatestRunOwner(uint agentId) public view returns (address) {
        return agentRuns[agentId].owner;
    }

    function compareStrings(
        string memory a,
        string memory b
    ) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }
}
