<template>
    <div class="container-fluid">
      <h2 class="text-center">Estadísticas de Pacientes</h2>
  
      <!-- Filtros en una sola fila -->
      <div class="row justify-content-center mb-4">
        <div class="col-md-1"></div> <!-- Columna a la izquierda -->
        <div class="col-md-10"> <!-- Contenido que ocupa 10 columnas -->
          <div class="row">
            <div class="col-md-3">
              <label for="hospital">Hospital</label>
              <select v-model="selectedHospital" class="form-control">
                <option value="">Todos los Hospitales</option>
                <option v-for="hospital in hospitales" :key="hospital" :value="hospital">{{ hospital }}</option>
              </select>
            </div>
            <div class="col-md-3">
              <label for="tipoConsulta">Tipo de Consulta</label>
              <select v-model="selectedTipoConsulta" class="form-control">
                <option value="">Todas las Consultas</option>
                <option value="Pediatría">Pediatría</option>
                <option value="CGI">CGI</option>
                <option value="Urgencia">Urgencia</option>
              </select>
            </div>
            <div class="col-md-3">
              <label for="fechaInicio">Fecha Inicio</label>
              <input type="date" v-model="fechaInicio" class="form-control" />
            </div>
            <div class="col-md-3">
              <label for="fechaFin">Fecha Fin</label>
              <input type="date" v-model="fechaFin" class="form-control" />
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-md-12 text-center">
              <button @click="filtrarEstadisticas" class="btn btn-primary">Filtrar</button>
            </div>
          </div>
        </div>
        <div class="col-md-1"></div> <!-- Columna a la derecha -->
      </div>
  
      <!-- Tabla de Estadísticas -->
      <div class="row justify-content-center">
        <div class="col-md-10">
          <table class="table table-bordered mt-4" v-if="estadisticas.length > 0">
            <thead>
              <tr>
                <th>Estado Consulta</th>
                <th>Número de Pacientes</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in estadisticas" :key="index">
                <td>{{ item.Estado_Consulta }}</td>
                <td>{{ item.Numero_Pacientes }}</td>
              </tr>
            </tbody>
          </table>
          <div v-else>
            <p>No hay estadísticas disponibles.</p>
          </div>
        </div>
      </div>
  
      <!-- Gráfico -->
      <div class="row justify-content-center">
        <div class="col-md-6"> <!-- Tamaño del gráfico reducido -->
          <canvas id="estadisticaChart"></canvas>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  import axios from 'axios';
  import { Chart, registerables } from 'chart.js';
  
  // Registrar todos los componentes de Chart.js
  Chart.register(...registerables);
  
  export default {
    data() {
      return {
        estadisticas: [],
        hospitales: ['Hospital A', 'Hospital B', 'Hospital C'], // Opcionalmente carga estos desde el backend
        selectedHospital: '',
        selectedTipoConsulta: '',
        fechaInicio: '',
        fechaFin: '',
        chart: null,
      };
    },
    mounted() {
      // Establecer las fechas predeterminadas
      const today = new Date().toISOString().substr(0, 10);
      const lastWeek = new Date();
      lastWeek.setDate(lastWeek.getDate() - 7);
      this.fechaInicio = lastWeek.toISOString().substr(0, 10);
      this.fechaFin = today;
  
      this.filtrarEstadisticas();
    },
    methods: {
      filtrarEstadisticas() {
        const params = {
          hospital: this.selectedHospital || null,
          tipo_consulta: this.selectedTipoConsulta || null,
          fecha_inicio: this.fechaInicio || null,
          fecha_fin: this.fechaFin || null,
        };
  
        axios.get('http://127.0.0.1:5003/api/estadistica', { params })
          .then(response => {
            this.estadisticas = response.data;
            this.renderChart(); // Renderizar el gráfico después de cargar los datos
          })
          .catch(error => {
            console.error('Error al cargar las estadísticas:', error);
          });
      },
      renderChart() {
        // Destruir el gráfico anterior antes de crear uno nuevo
        if (this.chart) {
          this.chart.destroy();
        }
  
        // Colores para los diferentes estados de los pacientes
        const colors = {
          'En Espera': 'rgba(255, 99, 132, 0.2)',
          'En Consulta': 'rgba(54, 162, 235, 0.2)',
          'Libre': 'rgba(75, 192, 192, 0.2)',
        };
  
        const borderColors = {
          'En Espera': 'rgba(255, 99, 132, 1)',
          'En Consulta': 'rgba(54, 162, 235, 1)',
          'Libre': 'rgba(75, 192, 192, 1)',
        };
  
        const estados = this.estadisticas.map(e => e.Estado_Consulta);
  
        const backgroundColors = estados.map(e => colors[e] || 'rgba(201, 203, 207, 0.2)');
        const borderColor = estados.map(e => borderColors[e] || 'rgba(201, 203, 207, 1)');
  
        // Crear el gráfico de barras
        const ctx = document.getElementById('estadisticaChart').getContext('2d');
        this.chart = new Chart(ctx, {
          type: 'bar',
          data: {
            labels: estados,
            datasets: [{
              label: 'Número de Pacientes',
              data: this.estadisticas.map(e => e.Numero_Pacientes),
              backgroundColor: backgroundColors,
              borderColor: borderColor,
              borderWidth: 1,
            }]
          },
          options: {
            responsive: true,
            scales: {
              y: {
                beginAtZero: true
              }
            }
          }
        });
      }
    }
  };
  </script>
  
  <style scoped>
  .container-fluid {
    margin-top: 20px;
  }
  .table {
    table-layout: auto;
    width: 100%;
  }
  .table th, .table td {
    text-align: center;
    vertical-align: middle;
  }
  </style>
  