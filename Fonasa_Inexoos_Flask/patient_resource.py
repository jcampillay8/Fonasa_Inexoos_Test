# patient_resource.py
from flask import jsonify
from flask_restful import Resource

def dictfetchall(cursor):
    columns = [col[0] for col in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]

class new_patient(Resource):
    def get(self):
        cur = mysql.connection.cursor()

        # Usar DISTINCT para eliminar duplicados
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
        if edad_paciente <= 15:
            grupo_edad = 'niño'
        elif 16 <= edad_paciente <= 40:
            grupo_edad = 'joven'
        else:
            grupo_edad = 'anciano'

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

        # Obtener los datos del paciente recién creado y los datos adicionales
        if grupo_edad == 'niño':
            cur.execute("""
                SELECT p.id, p.nombre_paciente, p.apellido_paciente, p.edad_paciente, p.grupo_edad, p.numero_historia_clinica, n.estatura, n.peso
                FROM patients p
                JOIN nino n ON p.id = n.Id_FK
                WHERE p.id = %s
            """, (patient_id,))
        elif grupo_edad == 'joven':
            cur.execute("""
                SELECT p.id, p.nombre_paciente, p.apellido_paciente, p.edad_paciente, p.grupo_edad, p.numero_historia_clinica, j.fumador, j.anos_fumando
                FROM patients p
                JOIN joven j ON p.id = j.Id_FK
                WHERE p.id = %s
            """, (patient_id,))
        elif grupo_edad == 'anciano':
            cur.execute("""
                SELECT p.id, p.nombre_paciente, p.apellido_paciente, p.edad_paciente, p.grupo_edad, p.numero_historia_clinica, a.dieta_asignada
                FROM patients p
                JOIN anciano a ON p.id = a.Id_FK
                WHERE p.id = %s
            """, (patient_id,))
        
        patient_data = dictfetchall(cur)
        cur.close()

        return jsonify({'Method': 'POST', 'message': 'Paciente creado exitosamente', 'patient_data': patient_data})


