<template>
  <div>
    <nav class="navigation">
      <router-link to="/">Hogar</router-link>|
      <router-link to="/consulta"> Consultas</router-link>|
      <router-link to="/lista_espera"> Lista Espera</router-link>|
      <router-link to="/tables"> Datos Pacientes</router-link>|
      <router-link to="/estadistica"> Estadística</router-link>
    </nav>
    <router-view />
  </div>
</template>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}

#app-container {
  background-color: #f5f5f5; /* Color de fondo plomo claro */
  min-height: 100vh; /* Asegura que cubra toda la pantalla */
  padding: 20px;
}

.navigation {
  font-size: 24px; /* Tamaño de la fuente más grande */
  font-weight: bold;
  padding: 30px;
  background-color: #e0e0e0; /* Color de fondo ligeramente más oscuro para la navegación */
  border-radius: 8px; /* Bordes redondeados para un toque más estilizado */
}

.navigation a {
  margin-right: 15px; /* Espaciado entre los enlaces */
  color: #2c3e50;
  text-decoration: none;
}

.navigation a.router-link-exact-active {
  color: #42b983;
}

.navigation a:hover {
  color: #0056b3; /* Color del enlace al hacer hover */
  text-decoration: underline; /* Subrayado al hacer hover */
}
</style>
