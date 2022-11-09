const networkConfig = {
    default: {
        name: "hardhat",
        interval: "30",
    },
    31337: {
        name: "localhost",
        interval: "30",
        callbackGasLimit: "500000", // 500,000 gas
    },
    5: {
        name: "goerli",
        interval: "30",
        callbackGasLimit: "500000", // 500,000 gas
    },
  }
  
  const developmentChains = ["hardhat", "localhost"]
  const VERIFICATION_BLOCK_CONFIRMATIONS = 6
  
  module.exports = {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
  }