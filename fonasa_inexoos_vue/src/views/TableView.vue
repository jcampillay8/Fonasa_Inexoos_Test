<template>
  <div class="container-fluid">
    <h2 class="alert alert-primary mt-2 text-center">Tablas Fonasa</h2>

    <!-- Filtros en una sola fila -->
    <div class="row mb-3" v-if="!isViewing && !isEditing">
      <div class="col-md-1"></div>
      <div class="col-md-2">
        <input 
          v-model="filters.id" 
          placeholder="Filtrar por Id"
          class="form-control"
        />
      </div>
      <div class="col-md-2">
        <input 
          v-model="filters.nombre" 
          placeholder="Filtrar por nombre"
          class="form-control"
        />
      </div>
      <div class="col-md-2">
        <input 
          v-model="filters.apellido" 
          placeholder="Filtrar por apellido"
          class="form-control"
        />
      </div>
      <div class="col-md-2">
        <input 
          v-model="filters.edad" 
          placeholder="Filtrar por edad"
          class="form-control"
        />
      </div>
      <div class="col-md-2">
        <input 
          v-model="filters.grupo_edad" 
          placeholder="Filtrar por grupo de edad"
          class="form-control"
        />
      </div>
    </div>

    <div class="row justify-content-center">
      <div class="col-md-1"></div>
      <!-- Tabla Pacientes -->
      <div class="col-md-10" v-if="!isEditing && !isViewing">
        <h2 class="alert alert-success text-center">Tabla Pacientes</h2>

        <table class="table table-bordered mt-4">
          <thead>
            <tr>
              <th scope="col">Id</th>
              <th scope="col">Nombre</th>
              <th scope="col">Apellido</th>
              <th scope="col">Edad</th>
              <th scope="col">Número Historia Clínica</th>
              <th scope="col">Grupo Edad</th>
              <th scope="col">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="patient in paginatedPatients" :key="patient.id">
              <td>{{ patient.id }}</td>
              <td>{{ patient.nombre_paciente }}</td>
              <td>{{ patient.apellido_paciente }}</td>
              <td>{{ patient.edad_paciente }}</td>
              <td>{{ patient.numero_historia_clinica }}</td>
              <td>{{ patient.grupo_edad }}</td>
              <td>
                <button @click="viewPatient(patient.id)" class="btn btn-primary btn-sm">Ver</button>
                <button @click="editPatient(patient.id)" class="btn btn-warning btn-sm ml-1">Editar</button>
                <button @click="deletePatient(patient.id)" class="btn btn-danger btn-sm ml-1">Eliminar</button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Paginación -->
        <div class="pagination d-flex justify-content-center">
          <button 
            class="btn btn-primary"
            :disabled="currentPage === 1"
            @click="prevPage">Anterior</button>

          <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>

          <button 
            class="btn btn-primary"
            :disabled="currentPage === totalPages"
            @click="nextPage">Siguiente</button>
        </div>
      </div>



            <!-- Columna vacía a la derecha -->
            <div class="col-md-"></div>
      <!-- Vista de Paciente -->
      <div class="col-md-10" v-if="isViewing">
        <h2 class="alert alert-info text-center">Detalles del Paciente</h2>
        <p><strong>ID:</strong> {{ currentPatient.id }}</p>
        <p><strong>Nombre:</strong> {{ currentPatient.nombre_paciente }}</p>
        <p><strong>Apellido:</strong> {{ currentPatient.apellido_paciente }}</p>
        <p><strong>Edad:</strong> {{ currentPatient.edad_paciente }}</p>
        <p><strong>Número Historia Clínica:</strong> {{ currentPatient.numero_historia_clinica }}</p>
        <p><strong>Grupo Edad:</strong> {{ currentPatient.grupo_edad }}</p>

        <button @click="closeView" class="btn btn-secondary mt-3">Volver</button>
      </div>
      
      <!-- Columna vacía a la derecha -->
      <div class="col-md-1"></div>

        <!-- Columna vacía a la derecha -->
        <div class="col-md-1"></div>
      <!-- Formulario de Edición de Paciente -->
      <div class="col-md-10" v-if="isEditing">
        <h2 class="alert alert-warning text-center">Editar Paciente</h2>
        <form @submit.prevent="updatePatient">
          <div class="form-group">
            <label>Nombre:</label>
            <input type="text" v-model="currentPatient.nombre_paciente" class="form-control" />
          </div>
          <div class="form-group">
            <label>Apellido:</label>
            <input type="text" v-model="currentPatient.apellido_paciente" class="form-control" />
          </div>
          <div class="form-group">
            <label>Edad:</label>
            <input type="number" v-model="currentPatient.edad_paciente" class="form-control" />
          </div>
          <div class="form-group">
            <label>Número Historia Clínica:</label>
            <input type="number" v-model="currentPatient.numero_historia_clinica" class="form-control" />
          </div>
          <div class="form-group">
            <label>Grupo Edad:</label>
            <input type="text" v-model="currentPatient.grupo_edad" class="form-control" />
          </div>

          <button type="submit" class="btn btn-success">Guardar Cambios</button>
          <button @click="closeEdit" class="btn btn-secondary ml-2">Cancelar</button>
        </form>
        
      </div>

      


    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      api: 'http://127.0.0.1:5000/api/patients/',
      patients: [],
      filters: {
        id: '',
        nombre: '',
        apellido: '',
        edad: '',
        grupo_edad: ''
      },
      currentPatient: {},
      isEditing: false,
      isViewing: false,
      currentPage: 1,
      itemsPerPage: 10,
    };
  },
  
  computed: {
    filteredPatients() {
      return this.patients.filter(patient => {
        return (
          (!this.filters.id || patient.id.toString().includes(this.filters.id.toString())) &&
          (!this.filters.nombre || patient.nombre_paciente.toLowerCase().includes(this.filters.nombre.toLowerCase())) &&
          (!this.filters.apellido || patient.apellido_paciente.toLowerCase().includes(this.filters.apellido.toLowerCase())) &&
          (!this.filters.edad || patient.edad_paciente.toString().includes(this.filters.edad.toString())) &&
          (!this.filters.grupo_edad || patient.grupo_edad.toLowerCase().includes(this.filters.grupo_edad.toLowerCase()))
        );
      });
    },
    totalPages() {
      return Math.ceil(this.filteredPatients.length / this.itemsPerPage);
    },
    paginatedPatients() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      return this.filteredPatients.slice(start, start + this.itemsPerPage);
    }
  },
  
  methods: {
    getPatients() {
      axios.get(this.api).then(response => {
        this.patients = response.data.patients;
      }).catch(error => {
        console.error('Error al obtener los pacientes:', error);
      });
    },

    viewPatient(id) {
      this.isViewing = true;
      this.isEditing = false;
      const selectedPatient = this.patients.find(patient => patient.id === id);
      if (selectedPatient) {
        this.currentPatient = { ...selectedPatient };
      }
    },

    editPatient(id) {
      this.isEditing = true;
      this.isViewing = false;
      const selectedPatient = this.patients.find(patient => patient.id === id);
      if (selectedPatient) {
        this.currentPatient = { ...selectedPatient };
      }
    },

    updatePatient() {
      axios.put(this.api, this.currentPatient).then(() => {
        this.getPatients();
        this.isEditing = false;
      }).catch(error => {
        console.error('Error al actualizar el paciente:', error);
      });
    },

    deletePatient(id) {
      axios.patch(this.api, { id }).then(() => {
        this.getPatients();
      }).catch(error => {
        console.error('Error al eliminar el paciente:', error);
      });
    },

    closeView() {
      this.isViewing = false;
      this.currentPatient = {};
    },

    closeEdit() {
      this.isEditing = false;
      this.currentPatient = {};
    },

    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },

    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    }
  },
  
  created() {
    this.getPatients();
  }
};
</script>
