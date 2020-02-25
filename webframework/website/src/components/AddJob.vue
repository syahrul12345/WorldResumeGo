<template>
	<v-row justify="center"> 
		<v-card 
			v-if="shown"
			:hover="true"
			:outline="20">
			<v-form
			ref="form"
			:lazy-validation="true">
				<v-container grid-list-xl>
					<v-layout shrink>
						<v-flex xs6>
							<v-combobox
							label="Company Name"
							v-model="companyName"
							:items="registeredEmployers"
							:append-icon="svgPath"
							:hint = "companyValidator"
							>
							</v-combobox>
						</v-flex>
						<v-flex xs6> 
							<v-text-field 
							label ="Position"
							v-model="position"
							>
							</v-text-field>
						</v-flex>
					</v-layout>
					<v-row justify="end">
						<v-col md="auto"> 
							<v-btn @click="startDialog=true"> Choose Start Date </v-btn>
								<v-row justify="center">
									<v-card>
									<v-dialog v-model="startDialog" persistent max-width="300px">
										<v-date-picker v-model="start":landscape="false" type="month" >
										</v-date-picker>
										 <v-btn
										 	dark
											:text="true" 
											@click="startDialog = false	">OK</v-btn>
										</v-dialog>
									</v-card>
								</v-row>
						</v-col>
						<v-col md="auto">
							<v-btn @click="endDialog=true"> Choose End Date </v-btn>
								<v-row justify="center">
									<v-card>
									<v-dialog v-model="endDialog" persistent max-width="300px">
										<v-date-picker v-model="end":landscape="false" type="month">
										</v-date-picker>
										<v-btn 
										dark
										:text="true" @click="endDialog = false">OK</v-btn>
									</v-dialog>
									</v-card>
								</v-row>
						</v-col>
						<v-col md="auto">
							<v-btn @click="save"> Save </v-btn>
						</v-col>
						<v-col md="auto">
							<v-btn @click="close"> Close </v-btn>
						</v-col>
					</v-row>
				</v-container>
				
			</v-form>
			<v-overlay :absolute="absolute" :value="overlay"> 
				<v-btn @click="edit"> EDIT </v-btn>
			</v-overlay>
			<v-dialog v-model="errorDialog" persistent max-width="300">
				<ErrorDialog :error="errorDialogText" v-on:close="errorDialog = !errorDialog"></ErrorDialog>
			</v-dialog>
		</v-card>
	</v-row>
</template>
<script>
	import { mdiArrowDownBox } from '@mdi/js';
	import ErrorDialog from './ErrorDialog.vue'
	export default {
		props:['id','registeredEmployers','employerHash'],
		components: {
			ErrorDialog
		},
		data() {
			return {
				shown:true,
				overlay:false,
				absolute:true,
				companyName:null,
				position:null,
				start:new Date().toISOString().substr(0, 7),
				end:new Date().toISOString().substr(0, 7),
				startDialog:false,
				endDialog:false,
				svgPath: mdiArrowDownBox,
				errorDialogText:null,
				errorDialog:false,
				collection: {},
				companyValidator: null
			}
		},
		watch: {
			companyName: function(newVal,oldVal) {
				if(this.employerHash[newVal] == undefined){
					this.companyValidator = "This company doesn't exist on the blockchain"
				}else{
					this.companyValidator = "This company is registered"
				}
			}
		},
		methods: {
			save(){
				let startYear = this.start.substring(0,4)
				let startMonth = this.start.substring(5)
				let endYear = this.end.substring(0,4)
				let endMonth = this.end.substring(5)
				const startDatum = Date.UTC(startYear,startMonth)
				const endDatum = Date.UTC(endYear,endMonth)
				this.$emit('save',{companyName:this.companyName,position:this.position,id:this.id,start:startDatum,end:endDatum,companyAddress:this.employerHash[this.companyName]})
				this.overlay = true
			},
			close(){
				this.$emit('close',{id:this.id})
				this.shown = false
			},
			edit(){
				this.overlay = false
			},
			allJobs(){
				this.companyDropDownField = true
			}
			
			
		}
	}
</script>
<style></style>