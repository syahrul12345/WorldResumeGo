<template>
	<v-card dark>
		<v-card-text> 
		<p class="mb-0"> Attempting to verify the job status...</p>
		<a 
		target="_blank" rel="noopener noreferrer"
		:href="explorerLink"><p class="mb-0"> Watch the verification process while waiting...</p></a>
		<v-progress-linear
            indeterminate
            color="blue"
            class="mb-0"
          ></v-progress-linear>
		</v-card-text>
	</v-card>
</template>
<script>
	export default {
		props:['transactionHash'],
		data() {
			return {
				created: true,
				explorerLink:null
			}
		},
		created(){
			this.explorerLink = `https://ropsten.etherscan.io/tx/${this.transactionHash}`
		}
	}
</script>
<style>
	p {
		text-align: center;
		justify-content: center
	}
</style>