<template>
	<v-container>
		<v-row justify="center" align="center">
			<v-col md="auto">
				<v-row justify="center" align="center">
					<h1 id="myName"> {{name}} </h1>
				</v-row justify="center" align="center">
					<h2 id="about"> {{blurb}}</h2>
				<v-row justify="center" align="center">
					<h3 id="address"> {{resumeAddress}}</h3>
				</v-row>
			</v-col>
		</v-row>
		<v-layout wrap>
			<v-flex xs12>
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
						<span id="verify" v-else> Not Verified </span>
					</v-card-text>
					<v-card-text class= "pt-0">{{employer.position}}</v-card-text>
				</v-card>
			</v-flex>
		</v-layout>
		<v-row justify="center" align ="center">
			<v-col cols="auto">
				<v-btn> Edit </v-btn>
			</v-col>
			<v-col cols ="auto">
				<v-btn @click="share = !share"> Share </v-btn>
			</v-col>
		</v-row>
		<v-dialog v-model="loading" persistent max-width="300">
			<Loader :resumeAddress="tempResumeAddress"></Loader>
		</v-dialog>
		<v-dialog v-model="share" max-width="500">
			<Share :resumeAddress="tempResumeAddress"></Share>
		</v-dialog>
	</v-container>
</template>
<script>
	import {getContractInfo} from '../utils/ethereum.js'
	import Loader from "./../components/LoaderV2.vue"
	import Share from "./../components/Share.vue"
	const Web3 = require('web3')
	export default{
		title:'Employee Data',
		components: {
			Loader,
			Share
		},
		data() {
			return {
				name:null,
				blurb:null,
				employers:[],
				created:true,
				digitalIdentity:null,
				resumeAddress:null,
				tempResumeAddress:null,
				jobIds:null,
				web3:null,
				contract:null,
				loading:false,
				share:false,
			}
		},
		async created(){
			const self = this;
			const promiseArray = []
			promiseArray.push(ethereum.enable())
			promiseArray.push(getContractInfo())
			Promise.all(promiseArray).then((result)=>{
				
				self.web3 = new Web3(ethereum)
				self.contract = new self.web3.eth.Contract(result[1].portFolioABI,result[1].deployedAddress)
				const promiseArray2 = []
				try{
					promiseArray2.push(self.contract.methods.getPortfolioAddress().call({from:this.$route.params.resumeIdentity}))
					promiseArray2.push(self.contract.methods.getAllJobId(this.$route.params.resumeIdentity).call({from:this.$route.params.resumeIdentity}))
					Promise.all(promiseArray2).then((result) =>{
						self.tempResumeAddress = result[0]
						self.loading = true
						self.jobIds = result[1]
						const jobData = self.jobIds.map((item) => {
							//call the blockchain for each jobid
							const data = self.contract.methods.getJobById(this.$route.params.resumeIdentity,item).call()
							return data
						})
						Promise.all(jobData).then((result) => {
							const converted = result.map((item) => {
								//item[0] = name of company
								//item[1] = address of company
								//item[2] = position
								//itemp[3] = start
								//item[4] = end
								//item[5] = verificaiton

								const promiseArray = []
								promiseArray.push(self.bytes32ToString(self.web3,item[0]))
								promiseArray.push(self.bytes32ToString(self.web3,item[2]))
								const startDate = self.dateExtractor(new Date(Math.round(Number(item[3]))))
								const endDate = self.dateExtractor(new Date(Math.round(Number(item[4]))))
								const stringDate = startDate + ' - ' + endDate
								return Promise.all(promiseArray).then((result) =>{
									return { name:result[0], position:result[1], duration:stringDate,verified:item[5]}
								})
							})

							Promise.all(converted).then(async (results) => {
								result = await self.contract.methods
								.getDetails(this.$route.params.resumeIdentity)
								.call({from:this.$route.params.resumeIdentity})
								.then((results) => {
									return {name:results[0],blurb:results[1]}

								})

								self.name = result.name
								self.blurb = result.blurb
								self.resumeAddress =  self.tempResumeAddress
								self.employers = results
								self.loading = false
							})
						})
					})
				}catch(ex){
					console.log(ex.toString())
				}
			})
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
			}
		},
	}
</script>
<style>
	#myName {
		font-family: "Monaco";
		text-align: center;
		font-size:35px;
		color: white;
	}
	#about {
		font-family: "Monaco";
		text-align: center;
		font-size:25px;
		color: white;
	}
	#address {
		font-family: "Monaco";
		text-align: center;
		color:white;
	}
	#verify {
		float: right;
		margin-right:1%;
	}


</style>