# Usa una imagen de Python como base
FROM python:3.12-slim

# Instala las dependencias del sistema necesarias para mysqlclient y pkg-config
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev build-essential gcc pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de la aplicación al contenedor
COPY . .

# Instala las dependencias de Python
RUN pip install --no-cache-dir -r requirements.txt

# Expone los puertos necesarios
EXPOSE 5000
EXPOSE 5001
EXPOSE 5002
EXPOSE 5003

# Asegúrate de no establecer FLASK_APP aquí para permitir la flexibilidad
# FLASK_DEBUG se puede configurar globalmente, pero cada servicio manejará su propia aplicación
ENV FLASK_DEBUG=0

# El comando se especificará en docker-compose para cada servicio
CMD ["flask", "run", "--host=0.0.0.0"]
