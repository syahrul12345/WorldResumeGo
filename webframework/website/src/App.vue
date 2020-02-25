<template>
  <v-app>
    <v-app-bar 
    app 
    absolute 
    app
    id="header"
    >
    </v-app-bar>
    <v-content id = "animated">
      <router-view/>
    </v-content>
  </v-app>
</template>

<script>
import Home from './views/Home.vue'
export default {
  name: 'App',
  components: {
    Home
  },
  data: () => ({
    //
  }),
  
};
</script>
<style>
  #header {
    background-color: #4F4463;
    background-color:rgba(79,68,99,0.2);
  }
</style>
