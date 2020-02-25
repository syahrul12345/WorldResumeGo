const assert = require('assert')
const Web3 = require('web3')
const portfolio = require('./../build/contracts/PortfolioTest.json')
const provider = "http://127.0.0.1:8545"
const web3 = new Web3 (new Web3.providers.HttpProvider(provider), null, {
    transactionConfirmationBlocks: 1,
  })
let contract;


before(async() => {
	//create on contract instance
	accounts = await web3.eth.getAccounts();
	const name = "Syahrul Nizam"
	const blurb = web3.utils.fromAscii("Developer Advocate")
	contract = await new web3.eth.Contract(portfolio.abi)
	.deploy({
		data:portfolio.bytecode,
		arguments:[name,blurb]
	}).send({
		from:accounts[0],
		gasLimit:6721975,
		gasPrice:20000000000,
	})
	console.log("  Deploying a contract before the current test...")
	console.log(`  The contract address for this current test is: ${contract.options.address}`)
})


describe("Let's try to create new portfolio",() => {
	it("It deploys the contract" ,() => {
		assert.ok(contract.options.address)
	})
	
})


// async function main() {
// 	const accounts = await web3.eth.getAccounts();
// 	const contract = new web3.eth.Contract(portfolio.interface)
// 	contract.deploy({
// 			data:portfolio.bytecode
// 		}).send({
// 			from:accounts[0],
// 			gasLimit:6721975,
// 			gasPrice:20000000000,
// 		}).on('receipt',(receipt) => {
// 			console.log(receipt)
// 		}).on('transactionHash',(receipt) => {

// 		})
	
// }
// main()
