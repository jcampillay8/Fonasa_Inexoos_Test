<template>
  <div class="container-fluid">
    <h2 class="text-center">Lista de Espera</h2>
    <div class="row justify-content-center">
      <div class="col-lg-10"> <!-- Ocupa 10 columnas de ancho -->
        <table class="table table-bordered mt-4" v-if="listaEspera.length > 0">
          <thead>
            <tr>
              <th>ID Paciente</th>
              <th>Nombre Completo Paciente</th>
              <th>Tipo Consulta Asignado</th>
              <th>Prioridad</th>
              <th>Estado Consulta</th>
              <th>Número Atención</th>
              <th>Fecha Ingreso Consulta</th>
              <th>Hora Ingreso Consulta</th>
              <th>ID Especialista</th>
              <th>Nombre Especialista</th>
              <th>Especialidad Consulta</th>
              <th>Estado Especialista</th>
              <th>Nombre Hospital</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in listaEspera" :key="index">
              <td>{{ item.Id_FK_Paciente }}</td>
              <td>{{ item.Nombre_Completo_Paciente }}</td>
              <td>{{ item.Tipo_Consulta_Asignado }}</td>
              <td>{{ item.Prioridad }}</td>
              <td>{{ item.Estado_Consulta }}</td>
              <td>{{ item.Numero_Atencion }}</td>
              <td>{{ item.Fecha_Ingreso_Consulta }}</td>
              <td>{{ item.Hora_Ingreso_Consulta }}</td>
              <td>{{ item.Id_PK_Especialista }}</td>
              <td>{{ item.Nombre_Especialista }}</td>
              <td>{{ item.Especialidad_Consulta }}</td>
              <td>{{ item.Estado_Especialista }}</td>
              <td>{{ item.Nombre_Hospital }}</td>
              <td>
                <button v-if="item.Estado_Consulta === 'En Espera'"
                        @click="actualizarEstado(item.Id_FK_Paciente, 'En Consulta', 'Ocupado')"
                        class="btn btn-primary btn-sm">Atender Paciente</button>
                <button v-else-if="item.Estado_Consulta === 'En Consulta'"
                        @click="actualizarEstado(item.Id_FK_Paciente, 'Libre', 'Desocupado')"
                        class="btn btn-warning btn-sm">Liberar Paciente</button>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-else>
          <p>No hay datos disponibles en la lista de espera.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      listaEspera: []
    };
  },
  mounted() {
    this.loadListaEspera();
  },
  methods: {
    loadListaEspera() {
      axios.get('http://127.0.0.1:5002/api/lista_espera')
        .then(response => {
          this.listaEspera = response.data;
        })
        .catch(error => {
          console.error('Error al cargar la lista de espera:', error);
        });
    },
    actualizarEstado(idPaciente, nuevoEstadoConsulta, nuevoEstadoEspecialista) {
      const payload = {
        Id_FK_Paciente: idPaciente,
        Estado_Consulta: nuevoEstadoConsulta,
        Estado_Especialista: nuevoEstadoEspecialista
      };

      axios.post('http://127.0.0.1:5002/api/actualizar_estado', payload)
        .then(response => {
          alert(response.data.message);
          this.loadListaEspera();  // Recargar la lista de espera después de la actualización
        })
        .catch(error => {
          console.error('Error al actualizar los estados:', error);
        });
    }
  }
};
</script>

<style scoped>
.container {
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
