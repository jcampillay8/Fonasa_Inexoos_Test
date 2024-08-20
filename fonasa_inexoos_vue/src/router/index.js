import { createRouter, createWebHistory } from 'vue-router'
import ListaEspera from '../views/ListaEsperaView.vue'
import Patient from '../views/PatientView.vue'
import Consulta from '../views/ConsultaView.vue'
import Table from '../views/TableView.vue'
import Estadistica from '../views/EstadisticaView.vue'

const routes = [
  {
    path: '/',
    name: 'patient',
    component: Patient
  },
  {
    path: '/lista_espera',
    name: 'ListaEspera',
    component: ListaEspera
  },
  {
    path: '/tables',
    name: 'table',
    component: Table
  },
  {
    path: '/consulta',
    name: 'Consulta',
    component: Consulta
  },
  {
    path: '/estadistica',
    name: 'Estadistica',
    component: Estadistica
  },
  
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
