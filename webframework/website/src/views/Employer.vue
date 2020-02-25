<template>
	<v-container>
		<v-row justify="center">
			<v-col cols="auto" >
				<v-row>
					<v-col cols="auto">
						<v-card
						:text="true"
						:flat="true"
						:outlined="true"
						color="rgba(0,0,0,0)"
						>
							<p id="cardHeader"> Register an Employer Identity</p>
							<p id="cardInfo">Are you an employer and would like to start verifying resumes? First create an employer identity</p>
							<v-row>
							<v-col cols="9" md="10" sm="10">
								<v-text-field
								label="Company Name"
								v-model="companyName"
								solo
								dark></v-text-field>
							</v-col>
							<v-col cols="2" md="2" sm="2"class="px2">
								<v-btn 
								dark
								class="my-1" @click="register"> Register </v-btn>
							</v-col>
							</v-row>
						</v-card>
					</v-col>
				</v-row>
			</v-col>
			<v-col cols="auto">
				<v-row>
					<v-col cols="auto">
						<v-card
						:text="true"
						:flat="true"
						:outlined="true"
						color="rgba(0,0,0,0)"
						>
							<p id="cardHeader"> Already Registered?</p>
							<p id="cardInfo">Verify that your employees have worked at your company. Start by searching for their Resume Address below.</p>
							<v-row>
								<v-col cols="9" md="10" sm="10">
									<v-text-field
									label="Resume Address"
									v-model="resumeAddress"
									:hint="addressValidator"
									solo
									dark>
									</v-text-field>
								</v-col>
								<v-col cols="2" md="2" sm="2"class="px2">
									<v-btn 
									dark
									class="my-1"
									:disabled="!checkSummed"
									@click="search"> Search </v-btn>
								</v-col>
							</v-row>
						</v-card>
					</v-col>
				</v-row>
			</v-col>
			<v-dialog v-model="errorDialog" persistent max-width="300">
				<v-card>
					<v-card-text> Please change to the ropsten testnet, this page will refresh automatically, once you have changed networks in your metamask extension</v-card-text>
				</v-card>
			</v-dialog>
			<v-dialog v-model="errorCall" persistent max-width="300">
				<ErrorDialog :error="errorMessage" v-on:close="errorCall =! errorCall"></ErrorDialog>
			</v-dialog>
			<v-dialog v-model="registerLoading" persistent max-width="300">
					<Loader :transactionHash="transactionHash"></Loader>
			</v-dialog>
		</v-row>
	</v-container>
</template>
<script>
	const Web3 = require('web3')
	import {getPortfolioInfo,getEmployerTracker} from './../utils/ethereum.js'
	import ErrorDialog from './../components/ErrorDialog.vue'
	import Loader from './../components/Loader.vue'
	export default {
		title:'Employers',
		props:[],
		components:{
			ErrorDialog,
			Loader
		},
		data() {
			return {
				created:true,
				errorDialog:false,
				resumeAddress:null,
				companyName:null,
				addressValidator:"This isn't a valid Ethereum address",
				web3:null,
				checkSummed:false,
				resumeContract:null,
				errorMessage:null,
				errorCall:null,
				registerLoading:false,
				loadingText:null,
				transactionHash:null,
			}
		},
		mounted() {
			if(!window.ethereum){
				this.errorMessage = "No Metamask detected, are you on mobile?"
				this.errorDialog = true
			}else{
				var error = this.checkNetwork()
				if(error != true){
					this.web3 = new Web3(ethereum)
				}
			}
		},
		watch: {
			//watched changes in the reusme address
			resumeAddress: function(newVal,oldVal){
				if(newVal != null){
					try{
						this.checkSummed = this.web3.utils.checkAddressChecksum(newVal)
						if(this.checkSummed == true){
							this.addressValidator = "This is a valid etheruem address"
						}else{
							this.addressValidator = "This isn't a valid Ethereum address"
						}
					}catch(ex){

					}
				}
				
			}
		},
		methods: {
			closeDialog() {
				this.errorDialog = false;
			},
			checkNetwork(){
				window.web3.version.getNetwork((err,id) => {
					if(id != 3){
						this.errorMessage = "You are not on the ropsten testnet,please change before proceeding. We are not responsible for your loss of ethers."
						this.errorDialog = true
						return true
					}

				})
				return false
			},
			async search(){
				const results = await getPortfolioInfo()
				const abi = results.portFolioABI
				this.resumeContract = new this.web3.eth.Contract(abi,this.resumeAddress)
				this.resumeContract.methods.getAllJobId().call().then((result) => {
					//go to the employee version of the resume page
					this.$router.push(`/Employerview/${this.resumeAddress}`)
				}).catch((error) => {
					this.errorMessage = "This account isn't a resume contract. Make sure to get the correct contract address!"
					this.errorCall = true
				})
				
			},
			async register(){
				const result = await getEmployerTracker()
				const abi = result.employerTrackerABI
				const address = result.deployedAddress
				const accounts = await ethereum.enable()
				const employerTracker = new this.web3.eth.Contract(abi,address)
				employerTracker.methods.register(this.stringToBytes32(this.companyName)).send({
					from:accounts[0]
				}).on('transactionHash',(transactionHash) => {
					this.transactionHash = transactionHash
					this.registerLoading = true
				}).on('receipt',(receipt) => {
					this.registerLoading = false
				}).on('error',(error) => {
					this.registerLoading = false
					this.errorCall = true
					this.errorMessage = "Transaction failed, you have already registered as an employer"
				})
			},
			stringToBytes32(item) {
				return this.web3.utils.toHex(item)
			},
			bytes32ToString(item){
				return this.web3.utils.toAscii(item)
			}
		}
		
	}
</script>
<style>
@media(min-width: 600px){
	#cardHeader {
		font-family: "Monaco";
	    text-align: center;
	    font-size:25px;
	    color: white;
	}
	#cardInfo {
		font-family: "Monaco";
	    text-align: center;
	    font-size:18px;
	    color: white;
	}
}
@media(max-width : 600px){
	#cardHeader {
		font-family: "Monaco";
	    text-align: center;
	    font-size:15px;
	    color: white;
	}
	#cardInfo {
		font-family: "Monaco";
	    text-align: center;
	    font-size:12px;
	    color: white;
	}
}
	
</style>