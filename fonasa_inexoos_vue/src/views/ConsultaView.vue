<template>
    <div class="container-fluid">
      <div class="row justify-content-center">
        
  
        <div class="col-md-12"> <!-- Contenedor principal de 10 columnas -->
          <h1 class="text-center">Consulta de Pacientes</h1>
  
          <!-- Botones -->
          <div class="button-container mt-4 text-center" v-if="!showFilters && !showForm">
            <button class="btn btn-primary" @click="showExistingPatient">Paciente Existente</button>
            <button class="btn btn-secondary ml-2" @click="showNewPatient">Paciente Nuevo</button>
          </div>
  
          <!-- Paciente Existente -->
          <div class="row justify-content-center" v-if="showFilters">
            <ExistingPatient 
              :patients="patients" 
              :filters="filters"
              @view-patient="viewPatient"
              @edit-patient="editPatient"
              @delete-patient="deletePatient"
            />
          </div>
  
          <!-- Paciente Nuevo -->
          <div class="row justify-content-center" v-if="showForm">
            <NewPatient 
              :newPatient="newPatient" 
              :showAdditionalFields="showAdditionalFields"
              @submit-new-patient="submitNewPatient"
              @guardar-paciente="guardarPaciente"
            />
          </div>
  
          <!-- Mensaje de éxito -->
          <div v-if="showSuccessMessage" class="alert alert-success mt-4 text-center">
            <h4>¡Paciente guardado exitosamente!</h4>
            <p><strong>ID:</strong> {{ savedPatient.id }}</p>
            <!-- Detalles adicionales -->
          </div>
        </div>
  

      </div>
    </div>
  </template>
  
  <script>
  import ExistingPatient from '@/components/ExistingPatient.vue';
  import NewPatient from '@/components/NewPatient.vue';
  import axios from 'axios';
  
  export default {
    components: {
      ExistingPatient,
      NewPatient,
    },
    data() {
      return {
        patients: [],
        filters: { id: '', numero_historia_clinica: '' },
        newPatient: { nombre: '', apellido: '', edad: null, numero_historia_clinica: null },
        showForm: false,
        showFilters: false,
        showAdditionalFields: false,
        showSuccessMessage: false,
        savedPatient: {},
      };
    },
    methods: {
      showExistingPatient() {
        this.showFilters = true;
        this.showForm = false;
        this.getPatients(); // Cargar pacientes al hacer clic
      },
      showNewPatient() {
        this.showForm = true;
        this.showFilters = false;
      },
      getPatients() {
        // Obtener la lista de pacientes de la API
        axios.get('http://127.0.0.1:5000/api/patients/')
          .then(response => {
            this.patients = response.data.patients;
          })
          .catch(error => {
            console.error('Error al obtener los pacientes:', error);
          });
      },
      submitNewPatient(patient) {
        this.newPatient = { ...patient };
        this.showAdditionalFields = true;
      },
      guardarPaciente(patient) {
        // Calcular el grupo de edad basado en la edad del paciente
        if (patient.edad <= 15) {
            patient.grupo_edad = 'niño';
        } else if (patient.edad >= 16 && patient.edad <= 40) {
            patient.grupo_edad = 'joven';
        } else {
            patient.grupo_edad = 'anciano';
        }
  
        // Realizar la solicitud POST para guardar los datos del paciente
        axios.post('http://127.0.0.1:5000/api/patients/', patient)
            .then(response => {
            this.savedPatient = response.data.patient_data[0]; // Obtenemos los datos del paciente creado
            this.showSuccessMessage = true;
            this.showAdditionalFields = false;
            this.limpiarFormulario();
            })
            .catch(error => {
            console.error('Error al guardar el paciente:', error);
            });
        },
      limpiarFormulario() {
        this.newPatient = { nombre: '', apellido: '', edad: null, numero_historia_clinica: null };
        this.showForm = false;
        this.showFilters = false;
        this.showAdditionalFields = false;
      },
    },
  };
  </script>
  