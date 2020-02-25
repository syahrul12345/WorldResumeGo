import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
import Employee from "./views/Employee.vue"
import Verify from "./views/Verify.vue"
import Create from "./views/Create.vue"
import Employer from "./views/Employer.vue"
import EmployerView from "./views/EmployerView.vue"
Vue.use(Router);

export default new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
    	path:"/Employee/:resumeIdentity",
    	name:"employee",
    	component: Employee,
    },
    {
    	path:"/Verify",
    	name:"verify",
    	component: Verify
    },
    {
      path:"/Create",
      name:"create",
      component: Create
    },
    {
      path:"/Employers",
      name:"employer",
      component: Employer
    },
    {
      path:"/Employerview/:resumeIdentity",
      name:"employerview",
      component: EmployerView
    }
  ]
});
