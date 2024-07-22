## Proveably Random Raffle Contracts !

## About !

  This code is to create a smart contract lottery .

## Overview !

 1. Users can ether by paying for a ticket
    1. ticket fees are going to go to the winner during the draw 
 2. After X period of time , the lottery will automatically draw a winner
    1. And this will be done programatically 
 3. Using Chainlink AggregatorV3Interface & Ckainlink VRF & Chainlink Automation
    1. Chainlink AggregatorV3Interface -> ETH/USD
    2. Chainlink VRF -> Randomness
    3. Chainlink Automation -> Time based trigger

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (27956b3 2023-11-30T00:34:57.814781400Z)`


## Quickstart

```
git clone https://github.com/Lhoussaineph2001/Foundry_Raffle_Game-PH
cd Foundry_Raffle_Game-PH
forge build
```

# Features

- **Funding:** Users can fund the contract by sending Ether to it. The contract checks if the amount of Ether sent is equal to or greater than a minimum USD value calculated using the current ETH/USD price feed.

- **Withdrawal:** The owner of the contract can withdraw the accumulated funds. There are two withdrawal methods: a standard withdrawal and a more cost-efficient withdrawal that combines resetting the array of funders and sending the funds in a single transaction.

- **Getters Functions:** Provides getter functions to retrieve information about the contract, including the amount funded by a specific address, the list of funders, and the contract owner.

- **Fallback Functions:** Handles scenarios where someone sends Ether to the contract without explicitly calling the `fund` function.

# Usage

## Deploy:

```
forge script script/Deploy_Raffle.s.s.sol
```

## Testing

1. Unit
2. Integration
3. Forked


```
forge test
```

or 

```
// Only run test functions matching the specified regex pattern.

"forge test --mt testFunctionName" is deprecated. Please use 

forge test --match-test testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

### Test Coverage

```
forge coverage
```


# Deployment to a testnet or mainnet

1. Setup environment variables

You'll want to set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file, similar to what you see in `.env.example`.

- `PRIVATE_KEY`: The private key of your account (like from [metamask](https://metamask.io/)). **NOTE:** FOR DEVELOPMENT, PLEASE USE A KEY THAT DOESN'T HAVE ANY REAL FUNDS ASSOCIATED WITH IT.
  - You can [learn how to export it here](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-Export-an-Account-Private-Key).
- `SEPOLIA_RPC_URL`: This is url of the sepolia testnet node you're working with. You can get setup with one for free from [Alchemy](https://alchemy.com/?a=673c802981)

Optionally, add your `ETHERSCAN_API_KEY` if you want to verify your contract on [Etherscan](https://etherscan.io/).

2. Get testnet ETH

Head over to [faucets.chain.link](https://faucets.chain.link/) and get some testnet ETH. You should see the ETH show up in your metamask.

3. Deploy

```
forge script script/Deploy_Raffle.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

## Scripts

After deploying to a testnet or local net, you can run the scripts. 

Using cast deployed locally example: 

```
cast send <FUNDME_CONTRACT_ADDRESS> "addPlayer()" --value 0.1ether --private-key <PRIVATE_KEY>
```

or

```
forge script script/Interactions.s.sol --rpc-url sepolia  --private-key $PRIVATE_KEY  --broadcast
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`


# Formatting


To run code formatting:
```
forge fmt
```



## License

This smart contract is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Author

- **Lhoussaine Ait Aissa** (GitHub: [Lhoussaineph2001](https://github.com/Lhoussaineph2001))


# Thank you!

If you appreciated this, feel free to follow me or donate!

ETH/Arbitrum/Polygon/etc Address: 0x344d2EFF6823E4C59E6af62Cd0B9b3757d9ff85C

[![Lhoussaine Ait Aissa Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/lhoussaineph)
[![Lhoussaine Ait Aissa Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/lhoussaine-ait-aissa/)


