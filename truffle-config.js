var HDWalletProvider = require("truffle-hdwallet-provider");
const { mnemonic, rpc } = require('./password.js')
module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  contracts_build_directory: "./webframework/website/src/utils/contracts/",
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 8545,            // Standard Ethereum port (default: none)
     network_id: "*",       // Any network (default: none)
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic,rpc)
      },
      network_id:'*',
      gasPrice:11000000000,
      gas:4500000
    }
    
  },

  compilers: {
    solc: {
      version: "0.5.9",
      optimizer: {
            enabled: true,
            runs: 200
        }  
    }
  }
}
