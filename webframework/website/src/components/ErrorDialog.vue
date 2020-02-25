<template>
	<v-card v-if="dialog">
		<v-card-title>ERROR</v-card-title>
		<v-card-text>{{error}}</v-card-text>
		<v-card-actions>
			<v-btn :text="true" @click="$emit('close')"> OK </v-btn>
		</v-card-actions>
	</v-card>
</template>
<script>
	export default {
		props:['error'],
		data() {
			return {
				created:true,
				dialog:true
			}
		},
		mounted() {
		}

	}
</script>