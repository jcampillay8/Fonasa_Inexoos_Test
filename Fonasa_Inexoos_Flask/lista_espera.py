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

class ListaEsperaResource(Resource):
    def get(self):
        cur = mysql.connection.cursor()

        # Consulta para obtener los datos de la lista de espera
        query = """
        SELECT 
            ep.Id_FK_Paciente,
            CONCAT(p.nombre_paciente, ' ', p.apellido_paciente) AS Nombre_Completo_Paciente,
            ep.Tipo_Consulta_Asignado,
            ep.Prioridad,
            ep.Estado_Consulta,
            ep.Numero_Atencion,
            DATE_FORMAT(ep.fecha_ingreso_consulta, '%Y-%m-%d') AS fecha_ingreso_consulta,
            TIME_FORMAT(ep.hora_ingreso_consulta, '%H:%i:%s') AS hora_ingreso_consulta,
            e.Id_PK_Especialista,
            e.Nombre_Especialista,
            e.Especialidad_Consulta,
            es.Estado_Consulta AS Estado_Especialista,
            h.Nombre_Hospital
        FROM 
            estado_paciente ep
        JOIN 
            patients p ON ep.Id_FK_Paciente = p.id
        JOIN 
            especialista e ON ep.Id_FK_Especialista = e.Id_PK_Especialista
        JOIN 
            estado_especialista es ON e.Id_PK_Especialista = es.Id_FK_Especialista
        JOIN 
            hospital h ON ep.Id_FK_Hospital = h.Id_PK_Hospital;
        """

        cur.execute(query)
        rows = cur.fetchall()

        # Convertir los resultados a un formato de diccionario
        lista_espera = []
        for row in rows:
            lista_espera.append({
                'Id_FK_Paciente': row[0],
                'Nombre_Completo_Paciente': row[1],
                'Tipo_Consulta_Asignado': row[2],
                'Prioridad': row[3],
                'Estado_Consulta': row[4],
                'Numero_Atencion': row[5],
                'Fecha_Ingreso_Consulta': row[6] if row[6] else 'N/A',  # Verificar si la fecha existe
                'Hora_Ingreso_Consulta': row[7] if row[7] else 'N/A',   # Verificar si la hora existe
                'Id_PK_Especialista': row[8],
                'Nombre_Especialista': row[9],
                'Especialidad_Consulta': row[10],
                'Estado_Especialista': row[11],
                'Nombre_Hospital': row[12]
            })

        cur.close()
        
        return jsonify(lista_espera)


class ActualizarEstadoResource(Resource):
    def post(self):
        data = request.get_json()
        id_paciente = data.get('Id_FK_Paciente')
        estado_consulta = data.get('Estado_Consulta')
        estado_especialista = data.get('Estado_Especialista')

        if not id_paciente or not estado_consulta or not estado_especialista:
            return jsonify({'message': 'Faltan datos'}), 400

        try:
            cur = mysql.connection.cursor()

            # Actualizar el estado del paciente
            query_paciente = """
            UPDATE estado_paciente
            SET Estado_Consulta = %s
            WHERE Id_FK_Paciente = %s
            """
            cur.execute(query_paciente, (estado_consulta, id_paciente))

            # Actualizar el estado del especialista
            query_especialista = """
            UPDATE estado_especialista
            JOIN estado_paciente ON estado_especialista.Id_FK_Especialista = estado_paciente.Id_FK_Especialista
            SET estado_especialista.Estado_Consulta = %s
            WHERE estado_paciente.Id_FK_Paciente = %s
            """
            cur.execute(query_especialista, (estado_especialista, id_paciente))

            mysql.connection.commit()
            cur.close()

            return jsonify({'message': 'Estados actualizados correctamente'})
        except Exception as e:
            return jsonify({'error': str(e)}), 500

api.add_resource(ActualizarEstadoResource, '/api/actualizar_estado')


api.add_resource(ListaEsperaResource, '/api/lista_espera')

if __name__ == '__main__':
    app.run(port=5002, debug=True)
