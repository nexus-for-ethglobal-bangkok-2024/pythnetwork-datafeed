const { ethers } = require("ethers");

const { HermesClient } = require("@pythnetwork/hermes-client");

require("dotenv").config();

// Contract ABI
const contractABI = [
   "function exampleMethod(bytes[] calldata priceUpdate) public payable",
];

// Config
const config = {
    contractAddress: "0xc491C99787FDb2Baf00D27b81dFcda4d874c9F2F",
    sepoliaRPC: process.env.ALCHEMY_TESTNET_RPC_URL,
    privateKey: process.env.TESTNET_PRIVATE_KEY,
};

// Main Function
async function main() {
    // Initialize Ethereum provider, wallet, and contract
    const provider = new ethers.providers.JsonRpcProvider(config.sepoliaRPC);
    const wallet = new ethers.Wallet(config.privateKey, provider);
    const contract = new ethers.Contract(config.contractAddress, contractABI, wallet);

    // Initialize HermesClient
    const hermes = new HermesClient("https://hermes.pyth.network", {});

    // Define price feed IDs
    const priceIds = [
        "0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43", // BTC/USD
        "0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace", // ETH/USD
        "0x2b89b9dc8fdf9f34709a5b106b472f0f39bb6ca9ce04b0fd7f2e971688e2e53b" //USDT/USD

    ];

    try {
    
        // Get price feeds
        // You can also fetch price feeds for other assets by specifying the asset name and asset class.
        const priceFeeds = await hermes.getPriceFeeds("btc", "crypto");
        console.log(priceFeeds);

        // Fetch price updates
        const priceUpdates = await hermes.getLatestPriceUpdates(priceIds);
        // const bytes=ethers.utils.arrayify("0x" + priceUpdates.binary.data[0]);
        console.log("priceUpdates:", priceUpdates.parsed.map(p => p.price));

        const priceData = await contract.exampleMethod(priceUpdates, {
            value: ethers.utils.parseEther("0.01"),
            gasLimit:50000
        });
        
    } catch (error) {
        console.error("Error:", error);
    }
}

// Execute the main function
main().catch(console.error);
