
-- ################################################################################################
-- ################################## INSERT DUMMY DATA ###########################################
-- ################################################################################################

-- Insertar más datos en la tabla `patients`
INSERT INTO patients (id, nombre_paciente, apellido_paciente, edad_paciente, numero_historia_clinica, grupo_edad, fecha_ingreso_consulta, hora_ingreso_consulta) 
VALUES
(55, 'Juan', 'Cabrera', 11, 1001, 'niño', '2024-08-18', '12:56:45'),
(56, 'Ana', 'López', 25, 1002, 'joven', '2024-08-18', '12:56:45'),
(57, 'Carlos', 'González', 65, 1003, 'anciano', '2024-08-18', '12:56:45'),
(58, 'Lucía', 'Ramírez', 8, 1004, 'niño', '2024-08-18', '12:56:45'),
(59, 'María', 'Fernández', 30, 1005, 'joven', '2024-08-18', '12:56:45'),
(60, 'Pedro', 'Martínez', 50, 1006, 'anciano', '2024-08-18', '12:56:45'),
(61, 'Sofía', 'García', 4, 1007, 'niño', '2024-08-18', '12:56:45'),
(62, 'Miguel', 'Torres', 20, 1008, 'joven', '2024-08-18', '12:56:45'),
(63, 'Fernando', 'Alvarez', 82, 1009, 'anciano', '2024-08-18', '12:56:45'),
(64, 'Camila', 'Diaz', 11, 1010, 'niño', '2024-08-18', '12:56:45'),
(65, 'Diego', 'Castillo', 38, 1011, 'joven', '2024-08-18', '12:56:45'),
(66, 'Isabel', 'Reyes', 70, 1012, 'anciano', '2024-08-18', '12:56:45'),
(67, 'Mario', 'Rivera', 9, 1013, 'niño', '2024-08-18', '12:56:45'),
(68, 'Laura', 'Sánchez', 22, 1014, 'joven', '2024-08-18', '12:56:45'),
(69, 'Rosa', 'Mendoza', 55, 1015, 'anciano', '2024-08-18', '12:56:45'),
(70, 'Daniel', 'Morales', 13, 1016, 'niño', '2024-08-18', '12:56:45'),
(71, 'Valeria', 'Ortiz', 28, 1017, 'joven', '2024-08-18', '12:56:45'),
(72, 'Juan', 'Cáceres', 72, 1018, 'anciano', '2024-08-18', '12:56:45'),
(73, 'Lucas', 'Hernández', 11, 1019, 'niño', '2024-08-18', '12:56:45'),
(74, 'Diana', 'Velásquez', 27, 1020, 'joven', '2024-08-18', '12:56:45'),
(75, 'Manuel', 'Suárez', 67, 1021, 'anciano', '2024-08-18', '12:56:45'),
(76, 'Raúl', 'Gómez', 26, 1022, 'joven', '2024-08-18', '12:56:45'),
(77, 'Alicia', 'Hernández', 29, 1023, 'joven', '2024-08-18', '12:56:45'),
(78, 'Andrés', 'Blanco', 35, 1024, 'joven', '2024-08-18', '12:56:45'),
(79, 'Sara', 'López', 41, 1025, 'anciano', '2024-08-18', '12:56:45'),
(80, 'José', 'Mena', 69, 1026, 'anciano', '2024-08-18', '12:56:45'),
(81, 'Gloria', 'Pérez', 78, 1027, 'anciano', '2024-08-18', '12:56:45'),
(82, 'Jaime', 'Campillay', 36, 5401, 'joven', '2024-08-19', '13:04:40'),
(83, 'Benjamin', 'Vicuña', 5, 9253, 'niño', '2024-08-19', '13:05:10'),
(84, 'Catalina', 'Rojo', 35, 5473, 'joven', '2024-08-19', '13:10:43'),
(85, 'Camilo', 'castaño', 55, 1625, 'anciano', '2024-08-19', '13:14:35'),
(86, 'Violeta', 'Parra', 12, 4710, 'niño', '2024-08-19', '13:20:30'),
(87, 'Carlos', 'Santana', 78, 1428, 'anciano', '2024-08-19', '14:19:10'),
(88, 'Marcos', 'Sprada', 8, 9892, 'niño', '2024-08-19', '14:20:01'),
(89, 'Amelie', 'Love', 33, 3788, 'joven', '2024-08-19', '14:26:42'),
(90, 'Ariel', 'Riveros', 38, 9893, 'joven', '2024-08-19', '15:23:41'),
(91, 'Pit', 'Martines', 29, 9894, 'joven', '2024-08-19', '19:12:41'),
(92, 'Pedro', 'Castillo', 55, 9895, 'anciano', '2024-08-19', '19:20:40');


-- Insertar más datos en la tabla `nino`
INSERT INTO nino (Id_FK, estatura, peso) 
VALUES
(55, 120, 35),
(58, 110, 40),
(61, 91, 22),
(64, 115, 28),
(67, 122, 40),
(70, 134, 40),
(73, 137, 70),
(83, 88, 20),
(86, 100, 23),
(88, 110, 35);


-- Insertar más datos en la tabla `joven`
INSERT INTO joven (Id_FK, fumador, anos_fumando) 
VALUES
(56, 1, 6),
(59, 0, 0),
(62, 1, 3),
(65, 0, 0),
(68, 0, 0),
(71, 1, 9),
(74, 0, 0),
(76, 1, 10),
(77, 0, 0),
(78, 1, 9),
(82, 1, 5),
(84, 1, 10),
(89, 1, 3),
(90, 1, 5),
(91, 1, 2);



-- Insertar más datos en la tabla `anciano`
INSERT INTO anciano (Id_FK, dieta_asignada) 
VALUES
(57, 1),
(60, 1),
(63, 1),
(66, 1),
(69, 0),
(72, 1),
(75, 0),
(79, 1),
(80, 0),
(81, 1),
(85, 1),
(87, 0),
(92, 1);


-- Insertar más datos en la tabla `hospital`
INSERT INTO `hospital` (`Nombre_Hospital`)
VALUES
('Hospital A'),
('Hospital B'),
('Hospital C');

-- Insertar más especialistas para Hospital A
INSERT INTO `especialista` (`Id_FK_Hospital`, `Nombre_Especialista`, `Especialidad_Consulta`)
VALUES
(1, 'Ana Pediatra', 'Pediatría'),
(1, 'Alberto Urgencias', 'Urgencia'),
(1, 'Andrés CGI', 'CGI'),
(1, 'Alejandra Pediatra', 'Pediatría'),
(1, 'Armando Urgencias', 'Urgencia'),
(1, 'Adriana CGI', 'CGI');

-- Insertar más especialistas para Hospital B
INSERT INTO `especialista` (`Id_FK_Hospital`, `Nombre_Especialista`, `Especialidad_Consulta`)
VALUES
(2, 'Beatriz Pediatra', 'Pediatría'),
(2, 'Bruno Urgencias', 'Urgencia'),
(2, 'Bernardo CGI', 'CGI'),
(2, 'Bárbara Pediatra', 'Pediatría'),
(2, 'Benjamín Urgencias', 'Urgencia'),
(2, 'Berta CGI', 'CGI');

-- Insertar más especialistas para Hospital C
INSERT INTO `especialista` (`Id_FK_Hospital`, `Nombre_Especialista`, `Especialidad_Consulta`)
VALUES
(3, 'Carla Pediatra', 'Pediatría'),
(3, 'Carlos Urgencias', 'Urgencia'),
(3, 'Carmen CGI', 'CGI'),
(3, 'Claudia Pediatra', 'Pediatría'),
(3, 'Cristian Urgencias', 'Urgencia'),
(3, 'Catalina CGI', 'CGI');


-- Para los especialistas del Hospital A (Hospital 1)
INSERT INTO `estado_especialista` (`Id_FK_Especialista`, `Estado_Consulta`)
SELECT `Id_PK_Especialista`, 'Desocupado'
FROM `especialista`
WHERE `Id_FK_Hospital` = 1;

-- Para los especialistas del Hospital B (Hospital 2)
INSERT INTO `estado_especialista` (`Id_FK_Especialista`, `Estado_Consulta`)
SELECT `Id_PK_Especialista`, 'Desocupado'
FROM `especialista`
WHERE `Id_FK_Hospital` = 2;

-- Para los especialistas del Hospital C (Hospital 3)
INSERT INTO `estado_especialista` (`Id_FK_Especialista`, `Estado_Consulta`)
SELECT `Id_PK_Especialista`, 'Desocupado'
FROM `especialista`
WHERE `Id_FK_Hospital` = 3;


