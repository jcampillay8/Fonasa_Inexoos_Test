import os
from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from flask_mysqldb import MySQL 
from flask_cors import CORS
from datetime import timedelta
from patient_resource import new_patient
import json

app = Flask(__name__)
CORS(app)

load_dotenv(dotenv_path='./Fonasa_Inexoos_Flask/.env')  # Ruta al archivo .env

# Configurar la base de datos con las variables de entorno
app.config['MYSQL_HOST'] = os.getenv('MYSQL_HOST')
app.config['MYSQL_USER'] = os.getenv('MYSQL_USER')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD')
app.config['MYSQL_DB'] = os.getenv('MYSQL_DB')

mysql = MySQL(app)

api = Api(app)

def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

def serialize_timedelta(td):
    return str(td)

class Patient(Resource):
    def get(self):
        cur = mysql.connection.cursor()

        query = """
        SELECT DISTINCT p.id, p.nombre_paciente, p.apellido_paciente, p.edad_paciente, p.numero_historia_clinica, p.grupo_edad,
        n.estatura, n.peso, j.fumador, j.anos_fumando, a.dieta_asignada
        FROM patients p
        LEFT JOIN nino n ON p.id = n.Id_FK
        LEFT JOIN joven j ON p.id = j.Id_FK
        LEFT JOIN anciano a ON p.id = a.Id_FK
        """
        cur.execute(query)
        data = dictfetchall(cur)
        cur.close()

        print(data)  # Añade esta línea para ver los datos devueltos en la consola

        for patient in data:
            for key, value in patient.items():
                if isinstance(value, timedelta):
                    patient[key] = serialize_timedelta(value)
        
        return jsonify({'patients': data, 'Method': 'GET'})



    def post(self):
        data = request.get_json()
        nombre_paciente = data['nombre']
        apellido_paciente = data['apellido']
        edad_paciente = data['edad']

        # Generar automáticamente número de historia clínica secuencial
        cur = mysql.connection.cursor()
        cur.execute("SELECT MAX(numero_historia_clinica) FROM patients")
        max_historia_clinica = cur.fetchone()[0] or 1000
        numero_historia_clinica = max_historia_clinica + 1

        # Determinar grupo de edad
        grupo_edad = data.get('grupo_edad')

        # Insertar paciente en la tabla `patients`
        cur.execute(
            "INSERT INTO patients (nombre_paciente, apellido_paciente, edad_paciente, numero_historia_clinica, grupo_edad) "
            "VALUES (%s, %s, %s, %s, %s)", 
            (nombre_paciente, apellido_paciente, edad_paciente, numero_historia_clinica, grupo_edad)
        )
        mysql.connection.commit()
        
        # Obtener el ID del paciente recién insertado
        patient_id = cur.lastrowid

        # Insertar datos adicionales en las tablas correspondientes según el grupo de edad
        if grupo_edad == 'niño':
            estatura = data.get('estatura')
            peso = data.get('peso')
            cur.execute("INSERT INTO nino (Id_FK, estatura, peso) VALUES (%s, %s, %s)", (patient_id, estatura, peso))
        elif grupo_edad == 'joven':
            fumador = data.get('fumador')
            anos_fumando = data.get('anos_fumando', 0)
            cur.execute("INSERT INTO joven (Id_FK, fumador, anos_fumando) VALUES (%s, %s, %s)", (patient_id, fumador, anos_fumando))
        elif grupo_edad == 'anciano':
            dieta_asignada = data.get('dieta_asignada', False)
            cur.execute("INSERT INTO anciano (Id_FK, dieta_asignada) VALUES (%s, %s)", (patient_id, dieta_asignada))

        mysql.connection.commit()
        cur.close()

        return jsonify({'Method': 'POST', 'message': 'New patient created successfully'})



    def put(self):
        data = request.get_json()
        id = data['id']
        nombre_paciente = data['nombre_paciente']
        apellido_paciente = data['apellido_paciente']
        edad_paciente = data['edad_paciente']
        numero_historia_clinica = data['numero_historia_clinica']
        grupo_edad = data['grupo_edad']

        cur = mysql.connection.cursor()
        cur.execute("""
        UPDATE patients 
        SET nombre_paciente=%s, apellido_paciente=%s, edad_paciente=%s, numero_historia_clinica=%s, grupo_edad=%s
        WHERE id=%s 
        """, (nombre_paciente, apellido_paciente, edad_paciente, numero_historia_clinica, grupo_edad, id))

        # Actualizar los datos adicionales según el grupo de edad
        if grupo_edad == 'niño':
            estatura = data.get('estatura')
            peso = data.get('peso')
            cur.execute("UPDATE nino SET estatura=%s, peso=%s WHERE Id_FK=%s", (estatura, peso, id))
        elif grupo_edad == 'joven':
            fumador = data.get('fumador')
            anos_fumando = data.get('anos_fumando')
            cur.execute("UPDATE joven SET fumador=%s, anos_fumando=%s WHERE Id_FK=%s", (fumador, anos_fumando, id))
        elif grupo_edad == 'anciano':
            dieta_asignada = data.get('dieta_asignada')
            cur.execute("UPDATE anciano SET dieta_asignada=%s WHERE Id_FK=%s", (dieta_asignada, id))

        mysql.connection.commit()
        cur.close()

        return jsonify({'Method': 'PUT', 'message': 'Patient updated successfully'})

    def patch(self):
        data = request.get_json()
        print(data)
        id = data['id']

        cur = mysql.connection.cursor()
        cur.execute("DELETE FROM patients WHERE id=%s", (id,))
        mysql.connection.commit()
        cur.close()

        return jsonify({'Method': 'PATCH', 'message': 'Patient deleted successfully'})

api.add_resource(Patient, '/api/patients/')

if __name__ == '__main__':
    app.run(debug=True)
