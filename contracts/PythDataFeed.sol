pragma solidity ^0.8.27;
 
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";
 
contract PythDataFeed {
  IPyth pyth = IPyth(0xDd24F84d36BF92C65F92307595335bdFab5Bbd21);

  /**
     * This method is an example of how to interact with the Pyth contract.
     * Fetch the priceUpdate from Hermes and pass it to the Pyth contract to update the prices.
     * Add the priceUpdate argument to any method on your contract that needs to read the Pyth price.
     * See https://docs.pyth.network/price-feeds/fetch-price-updates for more information on how to fetch the priceUpdate.
 
     * @param priceUpdate The encoded data to update the contract with the latest price
     */
  function exampleMethod(bytes[] calldata priceUpdate) public payable {
    // Submit a priceUpdate to the Pyth contract to update the on-chain price.
    // Updating the price requires paying the fee returned by getUpdateFee.
    // WARNING: These lines are required to ensure the getPriceNoOlderThan call below succeeds. If you remove them, transactions may fail with "0x19abf40e" error.
    uint fee = pyth.getUpdateFee(priceUpdate);
    pyth.updatePriceFeeds{ value: fee }(priceUpdate);
 
    // Read the current price from a price feed if it is less than 60 seconds old.
    // Each price feed (e.g., ETH/USD) is identified by a price feed ID.
    // The complete list of feed IDs is available at https://pyth.network/developers/price-feed-ids
    bytes32 priceFeedId = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace; // ETH/USD
    PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceFeedId, 60);
  }


}
 

// contract PythDataFeed {
//     IPyth pyth = IPyth(0xDd24F84d36BF92C65F92307595335bdFab5Bbd21);

//     struct FormattedPrice {
//         string pair;
//         int64 price;
//         uint256 timestamp;
//         int32 expo;
//         uint confidence;
//     }

//     mapping(bytes32 => string) public pairNames;

//     constructor() {
//         // Crypto Pairs
//         pairNames[0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace] = "ETH/USD";
//         pairNames[0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43] = "BTC/USD";
//         pairNames[0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a] = "SOL/USD";
        
//         // Forex Pairs
//         pairNames[0x8ac0c70fff57e9aefdf5edf44b51d62c2d433653cbb2cf5cc06bb115af04d221] = "EUR/USD";
//         pairNames[0x5bc91f13e412c07599167bae86f07543f076a638962b8d6017ec19dab4a82814] = "GBP/USD";
        
//         // Stocks
//         pairNames[0x85bb7d0c73dc5ee6cb9d09c5aa71411019aaff1f35f719ec7926656398621641] = "AAPL/USD";
//         pairNames[0xc0c9d260d555e0b93a8f1c2ec0ca281a9b1c6cd5508d056f127d6cefad37a558] = "TSLA/USD";
//     }

//     function getMultiplePrices(
//         bytes[] calldata priceUpdate, 
//         bytes32[] calldata priceFeedIds
//     ) public payable returns (FormattedPrice[] memory) {
//         uint fee = pyth.getUpdateFee(priceUpdate);
//         pyth.updatePriceFeeds{ value: fee }(priceUpdate);

//         FormattedPrice[] memory prices = new FormattedPrice[](priceFeedIds.length);

//         for (uint i = 0; i < priceFeedIds.length; i++) {
//             PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceFeedIds[i], 60);
//             prices[i] = FormattedPrice({
//                 pair: pairNames[priceFeedIds[i]],
//                 price: price.price,
//                 timestamp: price.publishTime,
//                 expo: price.expo,
//                 confidence: price.conf
//             });
//         }

//         return prices;
//     }

//     function getCryptoPrices(bytes[] calldata priceUpdate) external payable returns (FormattedPrice[] memory) {
//         bytes32[] calldata cryptoFeeds;
//         assembly {
//             cryptoFeeds.offset := 0x60
//             cryptoFeeds.length := 3
//             mstore(add(cryptoFeeds.offset, 0x20), 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace) // ETH/USD
//             mstore(add(cryptoFeeds.offset, 0x40), 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43) // BTC/USD
//             mstore(add(cryptoFeeds.offset, 0x60), 0xeaa020c61cc479712813461ce153894a96a6c00b21ed0cfc2798d1f9a9e9c94a) // SOL/USD
//         }
//         return getMultiplePrices(priceUpdate, cryptoFeeds);
//     }

//     function getForexPrices(bytes[] calldata priceUpdate) external payable returns (FormattedPrice[] memory) {
//         bytes32[] calldata forexFeeds;
//         assembly {
//             forexFeeds.offset := 0x40
//             forexFeeds.length := 2
//             mstore(add(forexFeeds.offset, 0x20), 0x8ac0c70fff57e9aefdf5edf44b51d62c2d433653cbb2cf5cc06bb115af04d221) // EUR/USD
//             mstore(add(forexFeeds.offset, 0x40), 0x5bc91f13e412c07599167bae86f07543f076a638962b8d6017ec19dab4a82814) // GBP/USD
//         }
//         return getMultiplePrices(priceUpdate, forexFeeds);
//     }

//     function getStockPrices(bytes[] calldata priceUpdate) external payable returns (FormattedPrice[] memory) {
//         bytes32[] calldata stockFeeds;
//         assembly {
//             stockFeeds.offset := 0x40
//             stockFeeds.length := 2
//             mstore(add(stockFeeds.offset, 0x20), 0x85bb7d0c73dc5ee6cb9d09c5aa71411019aaff1f35f719ec7926656398621641) // AAPL/USD
//             mstore(add(stockFeeds.offset, 0x40), 0xc0c9d260d555e0b93a8f1c2ec0ca281a9b1c6cd5508d056f127d6cefad37a558) // TSLA/USD
//         }
//         return getMultiplePrices(priceUpdate, stockFeeds);
//     }

//     function getPrice(bytes[] calldata priceUpdate, bytes32 priceFeedId) public payable returns (FormattedPrice memory) {
//         uint fee = pyth.getUpdateFee(priceUpdate);
//         pyth.updatePriceFeeds{ value: fee }(priceUpdate);

//         PythStructs.Price memory price = pyth.getPriceNoOlderThan(priceFeedId, 60);

//         FormattedPrice memory formatted = FormattedPrice({
//             pair: pairNames[priceFeedId],
//             price: price.price,
//             timestamp: price.publishTime,
//             expo: price.expo,
//             confidence: price.conf
//         });

//         return formatted;
//     }
// }