# Prove of Prompt

## Local Development

1. `anvil`
2. open new terminal, run `./deploy.sh`
3. Go to [office repository](https://github.com/galadriel-ai/contracts/) `contracts/oracles`, run `python oracle.py` (Change CHAIN_ID to 31337 in oracle .env)
4. `./query.sh` to send LLM query
5. Wait oracle to respond, then `./claim.sh` to claim the token

## Test

`forge test --via-ir`

## Deploy

1. add [office oracle address](https://docs.galadriel.com/oracle-address) to `.env`
2. Change script `deploy.sh` to use oracle address
3. `./deploy.sh`
4. add agent address to `.env`
