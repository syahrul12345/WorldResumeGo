<template>
	<v-container fill-height align="center">
		<v-col cols=12>
			<v-row justify="center">
					<p id="digitalIdentity">Your Digital Identity is: </p>
			</v-row>
			<v-row justify="center">
					<v-col cols="auto">
						<p id="address">{{digitalIdentity}}</p>
					</v-col>
			</v-row>
			<v-row justify="center">
					<p v-if="resumeNotFound" id="errorText">Resume not found. If you've just created it, please wait for a few minutes.</p>
			</v-row>
			<v-row justify="center">
				<v-col cols="auto">
					<router-link
					:to="'/Create'"
					style="text-decoration: none">
					<v-btn right> Create </v-btn>
					</router-link>
				</v-col>
				<v-col cols="auto">
					<router-link
					:to="`/Employee/${digitalIdentity}`"
					style="text-decoration: none"
					>
					<v-btn> View </v-btn>
					</router-link>
				</v-col>
			</v-row>
		</v-col>  
			<v-dialog v-model="errorDialog" persistent max-width="300">
				<ErrorDialog :error="errorDialogText" v-on:close="closeDialog"></ErrorDialog>
			</v-dialog>
		</v-row>
		
	</v-container>
</template>
<script>
	import {getContractInfo} from '../utils/ethereum.js'
	import ErrorDialog from "./../components/ErrorDialog.vue"
	const Web3 = require('web3')
	export default {
		title:"Verification",
		components: {
			ErrorDialog
		},
		data() {
			return {
				created: null,
				metmask:null,
				resumeNotFound:false,
				digitalIdentity: null,
				resumeAddress:null,
				id:null,
				web3:null,
				contract:null,
				errorDialog:false,
				errorDialogText:null
			}
		},

		async created() {
			if(window.ethereum) {
				const accounts = await ethereum.enable()
				this.digitalIdentity = accounts[0]
				this.id=0
				//we also want to set the web3 & contract
				this.web3 = new Web3(ethereum)
				const results = await getContractInfo()
				const factoryAbi = results.portFolioABI
				const factoryAddress = results.deployedAddress
				this.contract = await new this.web3.eth.Contract(factoryAbi,factoryAddress)
			}else {
				console.log("No metamask")
			}
		},
		mounted() {
			var self = this
			ethereum.on('accountsChanged', async function (accounts) {
				const newAccounts = await ethereum.enable()
				self.digitalIdentity = newAccounts[0]

			})
		},
		beforeRouteEnter(to,from,next) {
			if(window.ethereum) {
				console.log("metamask detected")
				next()
			}else {
				console.log("no metamask")
				console.log("metamask should be checked for in the previous page")
				console.log(from)
				next(from)
			}
		},
		async beforeRouteLeave(to,from,next) {
			//first check for network ID
			window.web3.version.getNetwork((err,id) => {
				switch(id){
					case "1":
						console.log("mainnet")
						this.errorDialog = true
						this.errorDialogText = "Your are on mainnet - please change to ROPSTEN"
						break;
					case "3":
						console.log("you are on correct network")
						if(to.name == "employee") {
							this.contract.methods.getPortfolioAddress().call({from:this.digitalIdentity}).then((resumeAddress) => {
									if(resumeAddress !== '0x0000000000000000000000000000000000000000'){
										this.resumeNotFound = false
										next()
									}else {
										this.resumeNotFound = true
									}
							})
						}else {
							next()
						}
						break;
					default:
						console.log("this is an unknown network")
						break;
				}
			})

			
		},
		methods: {
			async createResume() {
				if(window.ethereum) {
					this.contract.methods.createPortfolio().send({
						from:this.digitalIdentity
					}).then((result) => {
						console.log(result)
					})
				}
			},
			closeDialog() {
				this.errorDialog = false
			}
		}
	}
</script>
<style>
@media(max-width: 600px){
	#digitalIdentity {
		font-family: "Monaco";
		text-align: center;
		font-size:25px;
		color: white;
	}
	#address {
		font-family: "Monaco";
		text-align: center;
		font-size:15px;
		color:white;
	}
	#errorText {
		font-family: "Monaco";
		text-align: center;
		font-size:25px;
		color: red;
	}

}
@media(min-width: 601px){
	#digitalIdentity {
		font-family: "Monaco";
		text-align: center;
		font-size:25px;
		color: white;
	}
	#address {
		font-family: "Monaco";
		text-align: center;
		font-size:20px;
		color:white;
	}
	#errorText {
		font-family: "Monaco";
		text-align: center;
		font-size:25px;
		color: red;
	}

}
	
</style>