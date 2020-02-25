<template>
	<v-row justify="center">
		<v-col cols="auto">
			<v-card>
				<v-card-title> {{name}} </v-card-title>
				<v-card-text> {{blurb}} </v-card-text>
				<v-card-text> {{resumeAddress}}</v-card-text>
			</v-card>
		</v-col>
		<v-col cols="auto" md="8">
			<v-card
				class="mb-4"
				dark
				:outline="false"
				:text="true"
				v-for="employer in employers"
				:key="employer.id">
					<v-card-title>{{employer.name}}</v-card-title>
					<v-card-text class="pb-0">{{employer.duration}} 
						<span id="verify" v-if="employer.verified == true"> Verified</span>
						<span id="verify" v-else> Not Verified. <v-btn @click="verify(employer.jobId)">Verify Now!</v-btn> </span>
					</v-card-text>
					<v-card-text class= "pt-0">{{employer.position}}</v-card-text>
				</v-card>
		</v-col>
		<v-dialog v-model="loading" persistent max-width="300">
			<Loader :resumeAddress="resumeAddress"></Loader>
		</v-dialog>
		<v-dialog v-model="loadingVerify" persistent max-width="300">
			<LoaderVerify :transactionHash="transactionHash"></LoaderVerify>
		</v-dialog>
		<v-dialog v-model="errorDialog" persistent max-width="300">
			<ErrorDialog :error="errorDialogText" v-on:close="closeDialog"></ErrorDialog>
		</v-dialog>
	</v-row>
</template>
<script>
	import Loader from "./../components/LoaderV2.vue"
	import LoaderVerify from "./../components/LoaderVerify.vue"
	import ErrorDialog from "./../components/ErrorDialog.vue"
	import {getPortfolioInfo} from '../utils/ethereum.js'
	const Web3 = require('web3')
	export default {
		title: 'resume',
		components: {
			Loader,
			ErrorDialog,
			LoaderVerify
		},
		data() {
			return {
				name:null,
				blurb:null,
				created: true,
				employers:null,
				loading:false,
				loadingVerify:false,
				resumeAddress:null,
				web3:null,
				contract:null,
				employers:[],
				errorDialog:false,
				errorDialogText:null,
				portfolio:null,
				transactionHash:null

			}
		},
		async created(){
			if(window.ethereum){
				this.web3 = new Web3(ethereum)
				this.resumeAddress = this.$route.params.resumeIdentity
				const result = await getPortfolioInfo()
				const abi = result.portFolioABI
				this.portfolio = new this.web3.eth.Contract(abi,this.resumeAddress)
				this.portfolio.methods.getAllJobId().call().then((result) => {
					this.loading = true;
					const promiseArray = []
					result.forEach((jobHash) => {
						promiseArray.push(this.portfolio.methods.getJobById(jobHash).call())
					})

					Promise.all(promiseArray).then((result) => {
						const converted = result.map((item) => {
								//item[0] = name of company
								//item[1] = address of company
								//item[2] = position
								//itemp[3] = start
								//item[4] = end
								//item[5] = verificaiton
								const promiseArray = []
								promiseArray.push(this.bytes32ToString(this.web3,item[0]))
								promiseArray.push(this.bytes32ToString(this.web3,item[2]))
								const startDate = this.dateExtractor(new Date(Math.round(Number(item[3]))))
								const endDate = this.dateExtractor(new Date(Math.round(Number(item[4]))))
								const stringDate = startDate + ' - ' + endDate
								return Promise.all(promiseArray).then((result) =>{
									return { name:result[0], position:result[1], duration:stringDate,address:item[1],jobId:item[6],verified:item[5]}
								})
						})
						Promise.all(converted).then((result) => {
							this.portfolio.methods.getDetails().call().then((result) =>{
								this.name = result[0]
								this.blurb = result[1]
							})
							this.employers = result
							this.loading = false;
						})
					})
				})
			}else{
				this.errorDialog = true
				this.errorDialogText = "Please install metamask"
			}
		},
		methods: {
			bytes32ToString: async(web3,item) => {
				return web3.utils.toAscii(item)
			},
			dateExtractor:(date) => {
				const monthNames = ["January", "February", "March", "April", "May", "June",
				  "July", "August", "September", "October", "November", "December"
				];
				return monthNames[date.getMonth()] + '-' + date.getUTCFullYear()
			},
			async verify(value) {
				if(window.ethereum){
					const accounts = await ethereum.enable()
					console.log("started verification")
					console.log(`job id to be verified ${value}`)
					this.portfolio.methods.verify(value).send({
						from:accounts[0]
					}).on('transactionHash',(transactionHash) => {
						this.transactionHash = transactionHash
						this.loadingVerify = true;
					}).on('receipt',(receipt) => {
						this.loadingVerify = false;
					}).on('error',(error) => {
						this.loadingVerify = false;
						this.errorDialogText = "Failed to verify. Most likely it's because you're not the employer, so you can't verify the job! Please process to register"
						this.errorDialog = true
					})
					console.log("watching for event")
					//watches the event being fired
					this.portfolio.events.Verified({
					}).on('data', function(event){
					    console.log(event); // same results as the optional callback above
					})
					

				}else{
					this.errorDialog = true
					this.errorDialogText = "Please install metamask"
				}
			},
			closeDialog() {
				this.errorDialog = false
			}
		}
	}
</script>
<style></style>