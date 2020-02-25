<template>
	<v-container fill-height>
		<v-layout justify="center">
			<v-flex xs10 offset-xs1>
				<v-card
				dark
				:hover="true">
					<v-container>
						<v-layout wrap>
							<v-flex xs12>
								<v-form
								ref="form"
								:lazy-validation="true">
									<v-text-field
									v-model="name"
									label="name">
									</v-text-field>
									<v-text-field
									v-model="blurb"
									label="Short Description About Yourself">
									</v-text-field>
									<AddJob
									class = "mb-5"
									v-for="i in addJobCards"
									:id="i"
									:registeredEmployers="registeredEmployers"
									:employerHash="employerHash"
									v-on:save="updateValue($event)"
									v-on:close="deleteValue($event)"
									>
									</AddJob>
								</v-form>
								<v-row justify="space-between">
									<v-col md="auto">
										<router-link
										:to="'/'">
										<v-btn class="mx-1"> Back </v-btn>
										</router-link>
										<v-btn @click="addJobCard"> Add Job</v-btn>
									</v-col>
									<v-col md="auto">
										<v-btn @click="confirm">Save to Blockchain </v-btn>
									</v-col>
									
								</v-row>
							</v-flex>
						</v-layout>
					</v-container>

				</v-card>
				<v-dialog v-model="transactionPending" persistent max-width="300">
					<Loader :transactionHash="transactionHash"></Loader>
				</v-dialog>
				<v-dialog v-model="errorDialog" persistent max-width="300">
					<ErrorDialog :error="errorDialogText" v-on:close="closeDialog"></ErrorDialog>
				</v-dialog>
				

				
				<!-- <v-overlay :absolute="true" :value="transactionPending">

				</v-overlay> -->
			</v-flex>
		</v-layout>
	</v-container>
</template>
<script>
	import AddJob from "../components/AddJob.vue"
	import ErrorDialog from "./../components/ErrorDialog.vue"
	import Loader from "./../components/Loader.vue"
	import {getContractInfo,getEmployerTracker} from '../utils/ethereum.js'
	const Web3 = require('web3')
	export default {
		title: 'Create',
		props:[],
		components:{
			AddJob,
			ErrorDialog,
			Loader,
		},
		data() {
			return {
				name: null,
				blurb:null,
				created:true,
				addJobCards:1,
				digitalIdentity:null,
				web3:null,
				contract:null,
				transactionPending:false,
				transactionHash:null,
				errorDialog:false,
				errorDialogText:null,
				employerTracker:null,
				registeredEmployers:null,
				employerHash:{},
				jobs: []
			}
		},
		async created() {
			//we want to create the web3 object upon creation of this page
			if(window.ethereum) {
				const accounts = await ethereum.enable()
				this.digitalIdentity = accounts[0]
				//we also want to set the web3 & contract
				this.web3 = new Web3(ethereum)
				const results = await getContractInfo()
				this.contract = new this.web3.eth.Contract(results.portFolioABI,results.deployedAddress)

				const employerResults = await getEmployerTracker()
				console.log(employerResult);
				this.employerTracker = new this.web3.eth.Contract(employerResults.employerTrackerABI,employerResults.deployedAddress)
				this.employerTracker.methods.getAllEmployers().call().then((result) => {
					this.registeredEmployers = this.bytes32ToString(result[0],this.web3)
					const employerAddresses = result[1]
					for(var i =0;i<this.registeredEmployers.length;i++){
						this.employerHash[this.registeredEmployers[i]] = employerAddresses[i]
					}
				})
			}else {
				console.log("No metamask")
			}
		},
		methods: {
			closeDialog() {
				this.errorDialog = false
			},
			updateValue(value){
				//find if the object key exists
				let item = this.jobs.find(e => e.id === value.id)
				if(item === undefined){
					this.jobs.push(value)
				}else {
					let index = this.jobs.findIndex(e => e.id === value.id)
					this.jobs[index] = value
				}
			},
			deleteValue(value){
				let index = this.jobs.findIndex(e=> e.id === value.id)
				this.jobs.splice(index,1)

			},
			addJobCard(){
				this.addJobCards++
			},
			confirm(){
				let _companyNames = []
				let _companyAddress = []
				let _positions=[]
				const _startTimes=[]
				const _endTimes=[]
				if(this.jobs.length != 0) {
					this.jobs.forEach((item) =>{
						_companyNames.push(item.companyName)
						_positions.push(item.position)
						_startTimes.push(item.start)
						_endTimes.push(item.end)
						if(item.companyAddress == null || item.companyAddress == undefined){
							//use the eth burn address
							_companyAddress.push('0x000000000000000000000000000000000000dEaD')
						}else{
							_companyAddress.push(item.companyAddress)
						}
					})
					_companyNames = this.stringToBytes32(_companyNames,this.web3)
					_positions = this.stringToBytes32(_positions,this.web3)
					try{
						this.contract.methods.createPortfolio(
							this.digitalIdentity,
							this.name,
							this.blurb,
							_companyNames,
							_companyAddress,
							_positions,
							_startTimes,
							_endTimes).send({
								from:this.digitalIdentity
							}).on('transactionHash',hash =>{
								//send the transaction and let's waiit
								this.transactionPending = true
								this.transactionHash = hash;
							}).on('receipt',receipt => {
								//transaction confirmed
								this.transactionPending = false
								this.$router.push(`/Employee/${this.digitalIdentity}`)
							}).on('error',error => {
								this.transactionPending = false
								this.errorDialog = true
								this.errorDialogText = error.toString()
							})
						}catch (ex){
							this.errorDialog = true
							this.errorDialogText = ex.toString()
							console.log(ex.toString())
						}
					}else{
						this.errorDialog = true
						this.errorDialogText = "Your resume needs some jobs :)"
					}
				
				

			},
			stringToBytes32: (stringArray,web3) => {
				const returnArray = []
				stringArray.forEach((item) => {
					returnArray.push(web3.utils.toHex(item))
					
				})
				return returnArray
			},
			bytes32ToString(bytes32Array,web3) {
				const returnArray = []
				bytes32Array.forEach((item) => {
					returnArray.push(web3.utils.toAscii(item))
				})
				return returnArray
			}

		}
	}
</script>
<style></style>