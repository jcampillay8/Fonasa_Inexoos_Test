<template>
  <div class="container-fluid">
    <h3 class="text-center">Ingresar Nuevo Paciente</h3>
    <div class="row justify-content-center">
      <div class="col-md-1"></div> <!-- Columna vacía a la izquierda -->
      <div class="col-md-10"> <!-- Columna principal de 10 columnas de ancho -->
        <form @submit.prevent="submitNewPatient">
          <div class="row mb-3">
            <div class="col-md-4">
              <input 
                v-model="localNewPatient.nombre" 
                placeholder="Nombre"
                class="form-control"
                required
              />
            </div>
            <div class="col-md-4">
              <input 
                v-model="localNewPatient.apellido" 
                placeholder="Apellido"
                class="form-control"
                required
              />
            </div>
            <div class="col-md-4">
              <input 
                v-model.number="localNewPatient.edad" 
                placeholder="Edad"
                type="number"
                class="form-control"
                required
              />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <input 
                v-model="localNewPatient.numero_historia_clinica" 
                placeholder="Número Historia Clínica"
                type="number"
                class="form-control"
                :readonly="true"
              />
            </div>
          </div>
          <div class="row">
            <div class="col-md-12 text-center">
              <button type="submit" class="btn btn-success">Ingresar</button>
            </div>
          </div>
        </form>
  
        <!-- Mostrar campos adicionales según la edad -->
        <div v-if="showAdditionalFields" class="mt-4">
          <div v-if="localNewPatient.edad >= 0 && localNewPatient.edad <= 15">
            <h4 class="text-center">Información Adicional para Niño</h4>
            <div class="row">
              <div class="col-md-6">
                <input 
                  v-model="localNewPatient.estatura" 
                  placeholder="Estatura (cm)"
                  type="number"
                  class="form-control"
                />
              </div>
              <div class="col-md-6">
                <input 
                  v-model="localNewPatient.peso" 
                  placeholder="Peso (kg)"
                  type="number"
                  class="form-control"
                />
              </div>
            </div>
          </div>
  
          <div v-if="localNewPatient.edad >= 16 && localNewPatient.edad <= 40">
            <h4 class="text-center">Información Adicional para Joven</h4>
            <div class="row">
              <div class="col-md-6 d-flex align-items-center">
                <label class="form-label mr-2">Fumador</label>
                <input 
                  type="checkbox" 
                  class="form-check-input ml-2"
                  v-model="localNewPatient.fumador"
                />
              </div>
              <div class="col-md-6" v-if="localNewPatient.fumador">
                <input 
                  v-model="localNewPatient.anos_fumando" 
                  placeholder="Años fumando"
                  type="number"
                  class="form-control"
                />
              </div>
            </div>
          </div>
  
          <div v-if="localNewPatient.edad >= 41">
            <h4 class="text-center">Información Adicional para Anciano</h4>
            <div class="row">
              <div class="col-md-6 d-flex align-items-center">
                <label class="form-label mr-2">Dieta Asignada</label>
                <input 
                  type="checkbox" 
                  class="form-check-input ml-2"
                  v-model="localNewPatient.dieta_asignada"
                />
              </div>
            </div>
          </div>
  
          <!-- Botón para guardar el paciente -->
          <div class="row mt-3">
            <div class="col-md-12 text-center">
              <button @click="guardarPaciente" class="btn btn-primary">Crear y Guardar Datos Paciente</button>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-1"></div> <!-- Columna vacía a la derecha -->
    </div>
  </div>
</template>
  
<script>
export default {
  props: ['newPatient', 'showAdditionalFields'],
  data() {
    return {
      localNewPatient: { ...this.newPatient },
    };
  },
  methods: {
    submitNewPatient() {
      this.$emit('submit-new-patient', this.localNewPatient);
    },
    guardarPaciente() {
      // Asignar número de historia clínica automáticamente en el frontend
      if (!this.localNewPatient.numero_historia_clinica) {
        this.localNewPatient.numero_historia_clinica = Math.floor(1000 + Math.random() * 9000);
      }
      
      this.$emit('guardar-paciente', this.localNewPatient);
    },
  },
};
</script>

<style scoped>
.container-fluid {
  margin-top: 20px;
}
</style>
