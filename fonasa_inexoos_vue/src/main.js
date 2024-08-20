import { createApp } from 'vue'
import App from './App.vue'
import router from '../src/router'
import '../src/resources/css/bootstrap.css'

const app = createApp(App)

app.use(router)  // Usa el router en la aplicación

app.mount('#app')
