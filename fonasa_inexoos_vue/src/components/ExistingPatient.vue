<template>
  <div class="container-fluid">
    <h2 class="alert alert-primary mt-2 text-center">Pacientes Existentes</h2>

    <!-- Filtros en una sola fila -->
    <div class="row mb-3" v-if="!selectedPatientId && !selectedHospitalConfirmed">
      <div class="col-md-1"></div>
      <div class="col-md-2">
        <input v-model="localFilters.id" placeholder="Filtrar por Id" class="form-control" />
      </div>
      <div class="col-md-2">
        <input v-model="localFilters.numero_historia_clinica" placeholder="Filtrar por Número Historia Clínica" class="form-control" />
      </div>
      <div class="col-md-2">
        <input v-model="localFilters.nombre" placeholder="Filtrar por Nombre" class="form-control" />
      </div>
      <div class="col-md-2">
        <input v-model="localFilters.apellido" placeholder="Filtrar por Apellido" class="form-control" />
      </div>
      <div class="col-md-2">
        <input v-model="localFilters.edad" placeholder="Filtrar por Edad" class="form-control" />
      </div>
      <div class="col-md-1"></div>
    </div>

    <!-- Contenido principal -->
    <div class="row justify-content-center" v-if="!selectedPatientId && !selectedHospitalConfirmed">
      <div class="col-md-10">
        <h3 class="alert alert-success text-center">Tabla de Pacientes</h3>

        <!-- Tabla de pacientes filtrados -->
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
                <button @click="requestConsultation(patient)" class="btn btn-primary btn-sm">Solicitar Consulta</button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- Paginación -->
        <div class="pagination d-flex justify-content-center">
          <button class="btn btn-primary" @click="prevPage" :disabled="currentPage === 1">Anterior</button>
          <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
          <button class="btn btn-primary" @click="nextPage" :disabled="currentPage === totalPages">Siguiente</button>
        </div>
      </div>
    </div>

    <!-- Dropdown de hospitales -->
    <div class="row justify-content-center" v-if="selectedPatientId && !selectedHospitalConfirmed">
      <div class="col-md-10">
        <h3 class="text-center">Seleccionar Hospital para Consulta</h3>
        <div class="mt-4">
          <select v-model="selectedHospital" class="form-control">
            <option disabled value="">Seleccione un Hospital</option>
            <option v-for="hospital in hospitals" :key="hospital.Id_PK_Hospital" :value="hospital.Id_PK_Hospital">{{ hospital.Nombre_Hospital }}</option>
          </select>
          <button @click="confirmHospital" class="btn btn-success mt-3">Confirmar Hospital</button>
          <button @click="cancelConsultation" class="btn btn-secondary mt-3 ml-2">Cancelar</button>
        </div>
      </div>
    </div>

    <!-- Tabla de especialistas y datos adicionales -->
<!-- Tabla de especialistas y datos adicionales -->
<div class="row justify-content-center" v-if="selectedHospitalConfirmed">
  <div class="col-md-10">
    <h3 class="text-center">Especialistas Disponibles - {{ selectedHospitalName }}</h3>
    <table class="table table-bordered mt-4" v-if="filteredSpecialists.length > 0">
  <thead>
    <tr>
      <th scope="col">ID Paciente</th>
      <th scope="col">Nombre Paciente</th>
      <th scope="col">ID Especialista</th>
      <th scope="col">Nombre Especialista</th>
      <th scope="col">Especialidad Consulta</th>
      <th scope="col">Estado Consulta</th>

      <!-- Columnas dinámicas según el grupo de edad -->
      <th v-if="grupoEdad === 'niño'" scope="col">Categoría Edad</th>
      <th v-if="grupoEdad === 'niño'" scope="col">IMC Categoria</th>
      <th v-if="grupoEdad === 'niño'" scope="col">Riesgo Edad</th>
      <th v-if="grupoEdad === 'niño'" scope="col">Prioridad</th>

      <th v-if="grupoEdad === 'joven'" scope="col">Factor Años Fumador</th>
      <th v-if="grupoEdad === 'joven'" scope="col">Factor Edad</th>
      <th v-if="grupoEdad === 'joven'" scope="col">Riesgo Edad</th>
      <th v-if="grupoEdad === 'joven'" scope="col">Prioridad</th>

      <th v-if="grupoEdad === 'anciano'" scope="col">Factor Edad</th>
      <th v-if="grupoEdad === 'anciano'" scope="col">Riesgo Edad</th>
      <th v-if="grupoEdad === 'anciano'" scope="col">Prioridad</th>
      <th scope="col">Consulta</th>
    </tr>
  </thead>
  <tbody>
    <tr v-for="specialist in filteredSpecialists" :key="specialist.Id_Paciente">
      <td>{{ selectedPatientId }}</td>
      <td>{{ selectedPatientName }}</td>
      <td>{{ specialist.Id_PK_Especialista }}</td>
      <td>{{ specialist.Nombre_Especialista }}</td>

      <!-- Filtrar la especialidad según prioridad y grupo de edad -->
      <td>
        <span v-if="grupoEdad === 'niño' && patientDetails.prioridad <= 4">Pediatría</span>
        <span v-else-if="(grupoEdad === 'joven' || grupoEdad === 'anciano') && patientDetails.prioridad <= 4">CGI</span>
        <span v-else>Urgencia</span>
      </td>

      <td>{{ specialist.Estado_Consulta }}</td>

      <!-- Datos dinámicos según el grupo de edad -->
      <td v-if="grupoEdad === 'niño'">{{ patientDetails.categoria_edad }}</td>
      <td v-if="grupoEdad === 'niño'">{{ patientDetails.IMC_Category }}</td>
      <td v-if="grupoEdad === 'niño'">{{ patientDetails.riesgo_edad }}</td>
      <td v-if="grupoEdad === 'niño'">{{ patientDetails.prioridad }}</td>

      <td v-if="grupoEdad === 'joven'">{{ patientDetails.anos_fumando_factor }}</td>
      <td v-if="grupoEdad === 'joven'">{{ patientDetails.factor_edad }}</td>
      <td v-if="grupoEdad === 'joven'">{{ patientDetails.riesgo_edad }}</td>
      <td v-if="grupoEdad === 'joven'">{{ patientDetails.prioridad }}</td>

      <td v-if="grupoEdad === 'anciano'">{{ patientDetails.factor_edad }}</td>
      <td v-if="grupoEdad === 'anciano'">{{ patientDetails.riesgo_edad }}</td>
      <td v-if="grupoEdad === 'anciano'">{{ patientDetails.prioridad }}</td>
      <td>
        <button @click="takeConsultation(specialist)" class="btn btn-primary btn-sm">Tomar Consulta</button>
      </td>
    </tr>
  </tbody>
</table>

    <div v-else>
      <p class="text-center">No hay especialistas disponibles.</p>
    </div>
  </div>
</div>


  </div>
</template>

<script>
import axios from 'axios';

export default {
  props: ['patients'],
  data() {
    return {
      localFilters: { id: '', numero_historia_clinica: '', nombre: '', apellido: '', edad: '' },
      currentPage: 1,
      itemsPerPage: 10,
      selectedPatientId: null, // ID del paciente seleccionado
      selectedPatientName: '', // Nombre del paciente seleccionado
      grupoEdad: '', // Grupo de edad del paciente seleccionado
      selectedHospital: '', // ID del hospital seleccionado
      selectedHospitalName: '', // Nombre del hospital seleccionado
      hospitals: [],
      specialists: [],
      selectedHospitalConfirmed: false, // Estado de la confirmación del hospital
      patientDetails: {}, // Detalles del paciente según el grupo de edad
    };
  },
  computed: {
    filteredPatients() {
      return this.patients.filter(patient => {
        return (
          (!this.localFilters.id || patient.id.toString().includes(this.localFilters.id)) &&
          (!this.localFilters.numero_historia_clinica || patient.numero_historia_clinica.toString().includes(this.localFilters.numero_historia_clinica)) &&
          (!this.localFilters.nombre || patient.nombre_paciente.toLowerCase().includes(this.localFilters.nombre.toLowerCase())) &&
          (!this.localFilters.apellido || patient.apellido_paciente.toLowerCase().includes(this.localFilters.apellido.toLowerCase())) &&
          (!this.localFilters.edad || patient.edad_paciente.toString().includes(this.localFilters.edad))
        );
      });
    },
    totalPages() {
      return Math.ceil(this.filteredPatients.length / this.itemsPerPage);
    },
    paginatedPatients() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      return this.filteredPatients.slice(start, start + this.itemsPerPage);
    },
    filteredSpecialists() {
      // Filtrar los especialistas según la prioridad y grupo de edad
      return this.specialists.filter(specialist => {
        if (this.grupoEdad === 'niño' && this.patientDetails.prioridad <= 4) {
          return specialist.Especialidad_Consulta === 'Pediatría';
        } else if ((this.grupoEdad === 'joven' || this.grupoEdad === 'anciano') && this.patientDetails.prioridad <= 4) {
          return specialist.Especialidad_Consulta === 'CGI';
        } else {
          return specialist.Especialidad_Consulta === 'Urgencia';
        }
      });
    }
  },
  methods: {
    requestConsultation(patient) {
      this.selectedPatientId = patient.id;
      this.selectedPatientName = patient.nombre_paciente;
      this.grupoEdad = patient.grupo_edad;
      this.loadHospitals(); // Cargar hospitales al seleccionar paciente
    },
    loadHospitals() {
      axios.get('http://127.0.0.1:5001/api/hospitals/')
        .then(response => {
          this.hospitals = response.data.hospitals;
        })
        .catch(error => {
          console.error('Error al cargar hospitales:', error);
        });
    },
    confirmHospital() {
      if (this.selectedHospital) {
        this.selectedHospitalConfirmed = true;

        // Encuentra el nombre del hospital seleccionado
        const selectedHospitalObj = this.hospitals.find(
          hospital => hospital.Id_PK_Hospital === this.selectedHospital
        );
        this.selectedHospitalName = selectedHospitalObj.Nombre_Hospital;

        this.loadPatientDetails(); // Cargar detalles del paciente tras confirmar el hospital
      }
    },
    loadPatientDetails() {
      axios
        .get("http://127.0.0.1:5001/api/patient_details/", {
          params: {
            paciente_id: this.selectedPatientId,
          },
        })
        .then((response) => {
          const data = response.data.patient_data;

          // Verificamos el grupo de edad y asignamos los valores apropiados
          if (this.grupoEdad === 'niño') {
            this.patientDetails = {
              categoria_edad: data[0],
              IMC_Category: data[1],
              riesgo_edad: data[2],
              prioridad: data[3],
            };
          } else if (this.grupoEdad === 'joven') {
            this.patientDetails = {
              anos_fumando_factor: data[0],
              factor_edad: data[1],
              riesgo_edad: data[2],
              prioridad: data[3],
            };
          } else if (this.grupoEdad === 'anciano') {
            this.patientDetails = {
              factor_edad: data[0],
              riesgo_edad: data[1],
              prioridad: data[2],
            };
          }

          console.log("Patient Details Loaded:", this.patientDetails);

          // Cargar especialistas tras cargar detalles del paciente
          this.loadSpecialists(this.selectedHospital);
        })
        .catch((error) => {
          console.error("Error al cargar detalles del paciente:", error);
        });
    },
    loadSpecialists(hospitalId) {
      axios.get('http://127.0.0.1:5001/api/specialists/', { 
        params: { 
          hospital_id: hospitalId,
          paciente_id: this.selectedPatientId  // Se añade el ID del paciente a la solicitud
        } 
      })
      .then(response => {
        console.log(response.data.specialists);  // Verifica la estructura de los datos aquí
        this.specialists = response.data.specialists;
      })
      .catch(error => {
        console.error('Error al cargar especialistas:', error);
      });
    },
    takeConsultation(specialist) {
      // Verificamos si specialist tiene un Id_PK_Especialista definido
      if (!specialist || !specialist.Id_PK_Especialista) {
        console.error('El especialista no tiene un ID definido');
        return;
      }

      // Datos que vamos a enviar en la solicitud POST
      const consultationData = {
        Id_FK_Paciente: this.selectedPatientId,
        Id_FK_Hospital: this.selectedHospital,
        Id_FK_Especialista: specialist.Id_PK_Especialista, // Asegurarse de que este valor esté definido
        Tipo_Consulta_Asignado: this.getConsultaAsignada(),
        Prioridad: this.patientDetails.prioridad,
        Numero_Atencion: this.getNextNumeroAtencion(),  // Lógica real para obtener el número de atención
        Estado_Consulta: 'En Espera'  // Estado inicial de la consulta
      };

      // Realizamos la solicitud POST para registrar la consulta
      axios.post('http://127.0.0.1:5001/api/consultation/', consultationData)
        .then(response => {
          console.log('Consulta registrada con éxito:', response.data);
          alert('Consulta registrada con éxito');
        })
        .catch(error => {
          console.error('Error al registrar la consulta:', error);
          alert('Error al registrar la consulta');
        });
    },
    getConsultaAsignada() {
      // Determina el tipo de consulta basado en la prioridad y el grupo de edad
      if (this.grupoEdad === 'niño' && this.patientDetails.prioridad <= 4) {
        return 'Pediatría';
      } else if ((this.grupoEdad === 'joven' || this.grupoEdad === 'anciano') && this.patientDetails.prioridad <= 4) {
        return 'CGI';
      } else {
        return 'Urgencia';
      }
    },
    getNextNumeroAtencion() {
      // Aquí puedes implementar lógica para obtener el próximo número de atención
      return 1; // Placeholder, debes reemplazarlo con la lógica real
    },
    cancelConsultation() {
      this.selectedPatientId = null;
      this.selectedPatientName = '';
      this.selectedHospitalConfirmed = false;
      this.selectedHospital = '';
      this.specialists = [];
    },
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage--;
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage++;
      }
    },
  },
};
</script>
