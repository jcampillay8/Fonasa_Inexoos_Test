from flask import Flask, jsonify, request
from flask_restful import Resource, Api
from flask_mysqldb import MySQL 
from flask_cors import CORS
from datetime import timedelta
import json

app = Flask(__name__)
CORS(app)


app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'BTC.100K.jc'
app.config['MYSQL_DB'] = 'Fonasa_Test' 

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
        cur.execute("SELECT * FROM patients")
        data = dictfetchall(cur)
        cur.close()

        # Convertir cualquier timedelta en un string
        for patient in data:
            for key, value in patient.items():
                if isinstance(value, timedelta):
                    patient[key] = serialize_timedelta(value)
        
        return jsonify({'patients': data, 'Method': 'GET'})

    def post(self):
        data = request.get_json()
        print(data)
        nombre_paciente = data['nombre_paciente']
        apellido_paciente = data['apellido_paciente']
        edad_paciente = data['edad_paciente']
        numero_historia_clinica = data['numero_historia_clinica']
        grupo_edad = data['grupo_edad']

        cur = mysql.connection.cursor()
        cur.execute(
            "INSERT INTO patients (nombre_paciente, apellido_paciente, edad_paciente, numero_historia_clinica, grupo_edad) "
            "VALUES (%s, %s, %s, %s, %s)", 
            (nombre_paciente, apellido_paciente, edad_paciente, numero_historia_clinica, grupo_edad)
        )
        mysql.connection.commit()
        cur.close()

        return jsonify({'Method': 'POST', 'message': 'New patient created successfully'})

    def put(self):
        data = request.get_json()
        print(data)
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