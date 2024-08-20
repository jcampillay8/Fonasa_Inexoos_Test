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

class EstadisticaResource(Resource):
    def get(self):
        hospital = request.args.get('hospital', None)
        tipo_consulta = request.args.get('tipo_consulta', None)
        fecha_inicio = request.args.get('fecha_inicio', None)
        fecha_fin = request.args.get('fecha_fin', None)

        cur = mysql.connection.cursor()

        query = """
        SELECT 
            Estado_Consulta,
            COUNT(*) AS Numero_Pacientes
        FROM 
            estado_paciente ep
        JOIN hospital h ON ep.Id_FK_Hospital = h.Id_PK_Hospital
        WHERE (%s IS NULL OR h.Nombre_Hospital = %s)
        AND (%s IS NULL OR ep.Tipo_Consulta_Asignado = %s)
        AND (%s IS NULL OR ep.fecha_ingreso_consulta BETWEEN %s AND %s)
        GROUP BY 
            Estado_Consulta;
        """

        cur.execute(query, (hospital, hospital, tipo_consulta, tipo_consulta, fecha_inicio, fecha_inicio, fecha_fin))
        rows = cur.fetchall()

        estadisticas = [{'Estado_Consulta': row[0], 'Numero_Pacientes': row[1]} for row in rows]

        print(estadisticas)

        cur.close()
        return jsonify(estadisticas)

api.add_resource(EstadisticaResource, '/api/estadistica')


if __name__ == '__main__':
    app.run(port=5003, debug=True)
