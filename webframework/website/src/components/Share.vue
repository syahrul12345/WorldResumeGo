<template>
	<v-card>
		<v-card-text>
			<v-row>
			<p class = "my-1">Share the link below as proof that your resume exists on the Blockchain!</p>
			</v-row>
			<v-row align="center" justify="center">
				<v-col cols="auto">
					<a :href="resumeLink" > Link </a>
				</v-col>
				<!-- <v-col cols="auto">
					<v-btn @click="copy" v-clipboard="() => value"> COPY</v-btn>
				</v-col> -->
				<button
				 @click="doCopy"
				>
				  Copy to clipboard
				</button>
			</v-row>
		</v-card-text>
	</v-card>
</template>
<script>
	export default{
		props:['resumeAddress'],
		data() {
			return{
				created:true,
				resumeLink:null
			}
		},
		created(){
			this.resumeLink = `https://ropsten.etherscan.io/address/${this.resumeAddress}`
		},
		methods: {
			doCopy: function () {
		        this.$copyText(this.resumeLink).then(function (e) {
		          console.log(e)
		        }, function (e) {
		          console.log(e)
		        })
		    }
		}
	}
</script>
<style></style>