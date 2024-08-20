import os
from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from flask_mysqldb import MySQL
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Configurar la base de datos con las variables de entorno
app.config['MYSQL_HOST'] = os.getenv('MYSQL_HOST')
app.config['MYSQL_USER'] = os.getenv('MYSQL_USER')
app.config['MYSQL_PASSWORD'] = os.getenv('MYSQL_PASSWORD')
app.config['MYSQL_DB'] = os.getenv('MYSQL_DB')

mysql = MySQL(app)
api = Api(app)

class HospitalResource(Resource):
    def get(self):
        cur = mysql.connection.cursor()
        cur.execute("SELECT Id_PK_Hospital, Nombre_Hospital FROM hospital")
        hospitals = cur.fetchall()
        cur.close()

        hospital_list = [{'Id_PK_Hospital': row[0], 'Nombre_Hospital': row[1]} for row in hospitals]
        return jsonify({'hospitals': hospital_list})

class SpecialistsResource(Resource):
    def get(self):
        hospital_id = request.args.get('hospital_id')
        paciente_id = request.args.get('paciente_id')  # Asumiendo que enviamos el ID del paciente
        
        if not hospital_id or not paciente_id:
            return jsonify({'message': 'hospital_id and paciente_id are required'}), 400

        cur = mysql.connection.cursor()
        
        # Consulta para obtener los especialistas que trabajan en el hospital seleccionado
        query = """
        SELECT e.Id_PK_Especialista, e.Nombre_Especialista, e.Especialidad_Consulta, es.Estado_Consulta, p.nombre_paciente, p.id
        FROM especialista e
        JOIN estado_especialista es ON e.Id_PK_Especialista = es.Id_FK_Especialista
        JOIN patients p ON p.id = %s
        WHERE e.Id_FK_Hospital = %s
        """
        
        cur.execute(query, (paciente_id, hospital_id))
        specialists = cur.fetchall()
        cur.close()

        # Convertir el resultado en una lista de diccionarios
        specialist_list = [
            {
                'Id_PK_Especialista': row[0],
                'Nombre_Especialista': row[1],
                'Especialidad_Consulta': row[2],
                'Estado_Consulta': row[3],
                'Nombre_Paciente': row[4],
                'Id_Paciente': row[5]
            } for row in specialists
        ]
        
        return jsonify({'specialists': specialist_list})



class PatientDetails(Resource):
    def get(self):
        patient_id = request.args.get('paciente_id')
        if not patient_id:
            return jsonify({'message': 'patient_id is required'}), 400

        cur = mysql.connection.cursor()

        # Consulta el grupo de edad del paciente
        cur.execute("SELECT grupo_edad FROM patients WHERE id = %s", (patient_id,))
        group = cur.fetchone()[0]

        if group == 'niño':
            query = """
            SELECT 
 
                CASE 
                    WHEN p.edad_paciente <= 5 THEN 3
                    WHEN p.edad_paciente >= 13 THEN 1
                    ELSE 2
                END AS categoria_edad,
                CASE
                    WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) < 18.5 THEN 0
                    WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 24.9 THEN 1
                    WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 29.9 THEN 2
                    WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 34.9 THEN 3
                    ELSE 4
                END AS IMC_Category,
                p.edad_paciente / 100 AS riesgo_edad,
                (
                    CASE 
                        WHEN p.edad_paciente <= 5 THEN 3
                        WHEN p.edad_paciente >= 13 THEN 1
                        ELSE 2
                    END
                    + 
                    CASE
                        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) < 18.5 THEN 0
                        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 24.9 THEN 1
                        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 29.9 THEN 2
                        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 34.9 THEN 3
                        ELSE 4
                    END
                    +
                    p.edad_paciente / 100
                ) AS prioridad
            FROM patients p
            JOIN nino n ON p.id = n.Id_FK
            WHERE p.id = %s
            """
        elif group == 'joven':
            query = """
            SELECT 
 
                j.anos_fumando / 4 AS anos_fumando_factor,
                2 AS factor_edad,
                p.edad_paciente / 100 AS riesgo_edad,
                (j.anos_fumando / 4) + 2 + (p.edad_paciente / 100) AS prioridad
            FROM patients p
            JOIN joven j ON p.id = j.Id_FK
            WHERE p.id = %s
            """
        elif group == 'anciano':
            query = """
            SELECT 

                CASE
                    WHEN a.dieta_asignada = 1 AND p.edad_paciente >= 60 
                    THEN (p.edad_paciente / 20) + 4
                    ELSE (p.edad_paciente / 30) + 3
                END AS factor_edad,
                (p.edad_paciente / 100) + 5.3 AS riesgo_edad,
                CASE
                    WHEN a.dieta_asignada = 1 AND p.edad_paciente >= 60 
                    THEN ((p.edad_paciente / 20) + 4) + ((p.edad_paciente / 100) + 5.3)
                    ELSE ((p.edad_paciente / 30) + 3) + ((p.edad_paciente / 100) + 5.3)
                END AS prioridad
            FROM patients p
            JOIN anciano a ON p.id = a.Id_FK
            WHERE p.id = %s
            """
        else:
            return jsonify({'message': 'Invalid group'}), 400
        
        cur.execute(query, (patient_id,))
        data = cur.fetchone()
        print('#################################')
        print(data)
        print('#################################')
        cur.close()

        return jsonify({'patient_data': data})

class ConsultationResource(Resource):
    def post(self):
        data = request.get_json()

        Id_FK_Paciente = data['Id_FK_Paciente']
        Id_FK_Hospital = data['Id_FK_Hospital']
        Id_FK_Especialista = data['Id_FK_Especialista']  # ID del especialista enviado desde el frontend
        Tipo_Consulta_Asignado = data['Tipo_Consulta_Asignado']
        Prioridad = data['Prioridad']
        Numero_Atencion = data['Numero_Atencion']
        Estado_Consulta = data['Estado_Consulta']

        cur = mysql.connection.cursor()

        # Insertar en la tabla estado_paciente
        cur.execute("""
            INSERT INTO estado_paciente 
            (Id_FK_Paciente, Id_FK_Hospital, Id_FK_Especialista, Tipo_Consulta_Asignado, Prioridad, Numero_Atencion, Estado_Consulta)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (Id_FK_Paciente, Id_FK_Hospital, Id_FK_Especialista, Tipo_Consulta_Asignado, Prioridad, Numero_Atencion, Estado_Consulta))
        
        mysql.connection.commit()
        cur.close()

        return jsonify({'message': 'Consulta registrada con éxito'})


api.add_resource(ConsultationResource, '/api/consultation/')


api.add_resource(PatientDetails, '/api/patient_details/')

api.add_resource(HospitalResource, '/api/hospitals/')


api.add_resource(SpecialistsResource, '/api/specialists/')

if __name__ == '__main__':
    app.run(port=5001, debug=True)