<template>
	<v-card dark>
		<v-card-text> 
		<p class="mb-0"> Pulling essential data from your resume contract on the Ethereum Blockchain...</p>
		<a 
		target="_blank" rel="noopener noreferrer"
		:href="explorerLink"><p class="mb-0"> Watch your resume while waiting...</p></a>
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
		props:['resumeAddress'],
		data() {
			return {
				created: true,
				explorerLink:null
			}
		},
		created(){
			this.explorerLink = `https://ropsten.etherscan.io/address/${this.resumeAddress}`
		}
	}
</script>
<style>
	p {
		text-align: center;
		justify-content: center
	}
</style>