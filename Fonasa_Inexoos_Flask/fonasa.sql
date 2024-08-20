-- phpMyAdmin SQL Dump
-- version 5.2.1deb3
-- https://www.phpmyadmin.net/
--
-- Host: localhost via UNIX socket
-- Generation Time: [fecha y hora cuando generes el dump]
-- Server version: 8.0.39-0ubuntu0.24.04.1 - (Ubuntu)
-- PHP Version: 8.3.6

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `Fonasa_Test`
--

-- --------------------------------------------------------

-- ################################################################################################
-- ###################################### PACIENTE ################################################
-- ################################################################################################

--
-- Table structure for table `patients`
--
CREATE TABLE `patients` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `nombre_paciente` varchar(255) NOT NULL,
    `apellido_paciente` varchar(255) NOT NULL,
    `edad_paciente` TINYINT UNSIGNED NOT NULL,
    `numero_historia_clinica` int(11) NOT NULL UNIQUE,
    `grupo_edad` varchar(50) NOT NULL,
    `fecha_ingreso_consulta` DATE NOT NULL DEFAULT (CURRENT_DATE), -- Fecha automática
    `hora_ingreso_consulta` TIME NOT NULL DEFAULT (CURRENT_TIME),   -- Hora automática
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



DELIMITER //

CREATE TRIGGER `set_grupo_edad` 
BEFORE INSERT ON `patients`
FOR EACH ROW
BEGIN
    IF NEW.edad_paciente BETWEEN 0 AND 15 THEN
        SET NEW.grupo_edad = 'niño';
    ELSEIF NEW.edad_paciente BETWEEN 16 AND 40 THEN
        SET NEW.grupo_edad = 'joven';
    ELSE
        SET NEW.grupo_edad = 'anciano';
    END IF;
END//

DELIMITER ;

-- ################################################################################################
-- ###################################### NIÑO ###################################################
-- ################################################################################################


-- Tabla `nino`
CREATE TABLE `nino` (
    `Id_PK` int(11) NOT NULL AUTO_INCREMENT,
    `Id_FK` int(11) NOT NULL, -- Este es el Id del paciente
    `estatura` TINYINT UNSIGNED NOT NULL,
    `peso` TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY (`Id_PK`),
    FOREIGN KEY (`Id_FK`) REFERENCES `patients`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Trigger para verificar que solo se insertan pacientes del grupo 'niño' en la tabla `nino`
DELIMITER //

CREATE TRIGGER `verify_nino` 
BEFORE INSERT ON `nino`
FOR EACH ROW
BEGIN
    DECLARE grupo VARCHAR(50);
    SELECT grupo_edad INTO grupo FROM patients WHERE id = NEW.Id_FK;
    IF grupo != 'niño' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no pertenece al grupo de edad niño.';
    END IF;
END//

DELIMITER ;

-- ################################################################################################
-- ###################################### JOVEN ###################################################
-- ################################################################################################


-- Tabla `joven`
CREATE TABLE `joven` (
    `Id_PK` int(11) NOT NULL AUTO_INCREMENT,
    `Id_FK` int(11) NOT NULL, -- Este es el Id del paciente
    `fumador` BOOLEAN NOT NULL,
    `anos_fumando` TINYINT UNSIGNED DEFAULT 0, -- Se supone que si no es fumador, es 0
    PRIMARY KEY (`Id_PK`),
    FOREIGN KEY (`Id_FK`) REFERENCES `patients`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Trigger para verificar que solo se insertan pacientes del grupo 'joven' en la tabla `joven`
DELIMITER //

CREATE TRIGGER `verify_joven` 
BEFORE INSERT ON `joven`
FOR EACH ROW
BEGIN
    DECLARE grupo VARCHAR(50);
    SELECT grupo_edad INTO grupo FROM patients WHERE id = NEW.Id_FK;
    IF grupo != 'joven' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El paciente no pertenece al grupo de edad joven.';
    END IF;
END//

DELIMITER ;

-- ################################################################################################
-- ###################################### ANCIANO #################################################
-- ################################################################################################


-- Tabla `anciano`
CREATE TABLE `anciano` (
    `Id_PK` int(11) NOT NULL AUTO_INCREMENT,
    `Id_FK` int(11) NOT NULL, -- Este es el Id del paciente
    `dieta_asignada` BOOLEAN NOT NULL,
    PRIMARY KEY (`Id_PK`),
    FOREIGN KEY (`Id_FK`) REFERENCES `patients`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- Trigger para verificar que solo se insertan pacientes del grupo 'anciano' y con edad >= 60 en la tabla `anciano`
-- Crear el nuevo trigger para verificar que solo se insertan pacientes del grupo 'anciano' y con edad >= 60
DELIMITER //

CREATE TRIGGER `verify_anciano`
BEFORE INSERT ON `anciano`
FOR EACH ROW
BEGIN
    DECLARE grupo VARCHAR(50);
    DECLARE edad TINYINT;

    -- Obtener el grupo de edad y la edad del paciente
    SELECT grupo_edad, edad_paciente 
    INTO grupo, edad 
    FROM patients 
    WHERE id = NEW.Id_FK;

    -- Verificar si el paciente pertenece al grupo 'anciano' y su edad es mayor o igual a 60
    IF grupo != 'anciano' OR edad < 60 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El paciente no pertenece al grupo de edad anciano o no tiene la edad mínima de 60 años.';
    END IF;
END //

DELIMITER ;



-- ################################################################################################
-- ###################################### HOSPITAL ################################################
-- ################################################################################################

CREATE TABLE `hospital` (
    `Id_PK_Hospital` int(11) NOT NULL AUTO_INCREMENT,
    `Nombre_Hospital` varchar(255) NOT NULL,
    PRIMARY KEY (`Id_PK_Hospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ################################################################################################
-- #################################### ESPECIALISTA ##############################################
-- ################################################################################################


CREATE TABLE `especialista` (
    `Id_PK_Especialista` int(11) NOT NULL AUTO_INCREMENT,
    `Id_FK_Hospital` int(11) NOT NULL, -- Este es el Id del hospital
    `Nombre_Especialista` varchar(255) NOT NULL,
    `Especialidad_Consulta` ENUM('Pediatría', 'Urgencia', 'CGI') NOT NULL,
    PRIMARY KEY (`Id_PK_Especialista`),
    FOREIGN KEY (`Id_FK_Hospital`) REFERENCES `hospital`(`Id_PK_Hospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE `estado_especialista` (
    `Id_FK_Especialista` int(11) NOT NULL, -- Este es el Id del especialista
    `Estado_Consulta` ENUM('Ocupado', 'Desocupado') NOT NULL,
    FOREIGN KEY (`Id_FK_Especialista`) REFERENCES `especialista`(`Id_PK_Especialista`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ################################################################################################
-- ################################## ESTADO PACIENTE #############################################
-- ################################################################################################

CREATE TABLE `estado_paciente` (
    `Id_PK` int(11) NOT NULL AUTO_INCREMENT,
    `Id_FK_Paciente` int(11) NOT NULL, -- Este es el Id del paciente
    `Id_FK_Hospital` int(11) NOT NULL, -- Este es el Id del hospital
    `Id_FK_Especialista` int(11) NOT NULL, -- Este es el Id del especialista
    `Tipo_Consulta_Asignado` ENUM('Pediatría', 'CGI', 'Urgencia') NOT NULL,
    `Prioridad` TINYINT UNSIGNED NOT NULL,
    `Numero_Atencion` TINYINT UNSIGNED NOT NULL,
    `Estado_Consulta` ENUM('En Espera', 'En Consulta', 'Libre') NOT NULL,
    `fecha_ingreso_consulta` DATE NOT NULL DEFAULT CURRENT_DATE, -- Fecha automática
    `hora_ingreso_consulta` TIME NOT NULL DEFAULT CURRENT_TIME, -- Hora automática
    PRIMARY KEY (`Id_PK`),
    FOREIGN KEY (`Id_FK_Paciente`) REFERENCES `patients`(`id`),
    FOREIGN KEY (`Id_FK_Hospital`) REFERENCES `hospital`(`Id_PK_Hospital`),
    FOREIGN KEY (`Id_FK_Especialista`) REFERENCES `especialista`(`Id_PK_Especialista`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- ################################################################################################
-- ################################ ESTADISTICA CONSULTAS #########################################
-- ################################################################################################


CREATE TABLE `estadistica_consultas` (
    `ID` int(11) NOT NULL AUTO_INCREMENT,
    `Id_FK_Paciente` int(11) NOT NULL, -- Este es el Id del paciente
    `Id_FK_Hospital` int(11) NOT NULL, -- Este es el Id del hospital
    `Tipo_Consulta` ENUM('Pediatría', 'CGI', 'Urgencia') NOT NULL,
    `Estado_Consulta` ENUM('En Espera', 'En Consulta', 'Libre') NOT NULL,
    `Hora_Ingreso_Consulta` TIME NOT NULL, -- Hora de ingreso tomada de la tabla Paciente
    `Fecha_Ingreso_Consulta` DATE NOT NULL, -- Fecha de ingreso tomada de la tabla Paciente
    `Hora_Salida` TIME NOT NULL,
    `Fecha_Salida` DATE NOT NULL,
    PRIMARY KEY (`ID`),
    FOREIGN KEY (`Id_FK_Paciente`) REFERENCES `patients`(`id`),
    FOREIGN KEY (`Id_FK_Hospital`) REFERENCES `hospital`(`Id_PK_Hospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ################################################################################################
-- ################################## INSERT DUMMY DATA ###########################################
-- ################################################################################################

-- Insertar más datos en la tabla `patients`
INSERT INTO `patients` (`nombre_paciente`, `apellido_paciente`, `edad_paciente`, `numero_historia_clinica`, `grupo_edad`, `fecha_ingreso_consulta`, `hora_ingreso_consulta`)
VALUES
('Juan', 'Pérez', 10, 1001, 'niño', CURRENT_DATE, CURRENT_TIME),
('Ana', 'López', 25, 1002, 'joven', CURRENT_DATE, CURRENT_TIME),
('Carlos', 'González', 65, 1003, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Lucía', 'Ramírez', 8, 1004, 'niño', CURRENT_DATE, CURRENT_TIME),
('María', 'Fernández', 30, 1005, 'joven', CURRENT_DATE, CURRENT_TIME),
('Pedro', 'Martínez', 75, 1006, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Sofía', 'García', 12, 1007, 'niño', CURRENT_DATE, CURRENT_TIME),
('Miguel', 'Torres', 19, 1008, 'joven', CURRENT_DATE, CURRENT_TIME),
('Fernando', 'Alvarez', 82, 1009, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Camila', 'Diaz', 11, 1010, 'niño', CURRENT_DATE, CURRENT_TIME),
('Diego', 'Castillo', 38, 1011, 'joven', CURRENT_DATE, CURRENT_TIME),
('Isabel', 'Reyes', 70, 1012, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Mario', 'Rivera', 9, 1013, 'niño', CURRENT_DATE, CURRENT_TIME),
('Laura', 'Sánchez', 22, 1014, 'joven', CURRENT_DATE, CURRENT_TIME),
('Rosa', 'Mendoza', 68, 1015, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Daniel', 'Morales', 13, 1016, 'niño', CURRENT_DATE, CURRENT_TIME),
('Valeria', 'Ortiz', 28, 1017, 'joven', CURRENT_DATE, CURRENT_TIME),
('Juan', 'Cáceres', 72, 1018, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Lucas', 'Hernández', 14, 1019, 'niño', CURRENT_DATE, CURRENT_TIME),
('Diana', 'Velásquez', 27, 1020, 'joven', CURRENT_DATE, CURRENT_TIME),
('Manuel', 'Suárez', 67, 1021, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Raúl', 'Gómez', 26, 1022, 'joven', CURRENT_DATE, CURRENT_TIME),
('Alicia', 'Hernández', 29, 1023, 'joven', CURRENT_DATE, CURRENT_TIME),
('Andrés', 'Blanco', 35, 1024, 'joven', CURRENT_DATE, CURRENT_TIME),
('Sara', 'López', 74, 1025, 'anciano', CURRENT_DATE, CURRENT_TIME),
('José', 'Mena', 69, 1026, 'anciano', CURRENT_DATE, CURRENT_TIME),
('Gloria', 'Pérez', 78, 1027, 'anciano', CURRENT_DATE, CURRENT_TIME);


-- Insertar más datos en la tabla `nino`
INSERT INTO `nino` (`Id_FK`, `estatura`, `peso`)
VALUES
(1, 120, 30),  -- Juan Pérez, id=1
(4, 110, 25),  -- Lucía Ramírez, id=4
(7, 130, 35),  -- Sofía García, id=7
(10, 115, 28),  -- Camila Diaz, id=10
(13, 122, 32),  -- Mario Rivera, id=13
(16, 134, 40),  -- Daniel Morales, id=16
(19, 137, 42);  -- Lucas Hernández, id=19


-- Insertar más datos en la tabla `joven`
INSERT INTO `joven` (`Id_FK`, `fumador`, `anos_fumando`)
VALUES
(2, TRUE, 5),  -- Ana López, id=2, fumadora por 5 años
(5, FALSE, 0), -- María Fernández, id=5, no fumadora
(8, TRUE, 3),  -- Miguel Torres, id=8, fumador por 3 años
(11, FALSE, 0), -- Diego Castillo, id=11, no fumador
(14, FALSE, 0), -- Laura Sánchez, id=14, no fumadora
(17, TRUE, 6),  -- Valeria Ortiz, id=17, fumadora por 6 años
(20, FALSE, 0), -- Diana Velásquez, id=20, no fumadora
(23, TRUE, 10), -- Raúl Gómez, id=23, fumador por 10 años
(25, FALSE, 0), -- Alicia Hernández, id=25, no fumadora
(27, TRUE, 7);  -- Andrés Blanco, id=27, fumador por 7 años


-- Insertar más datos en la tabla `anciano`
INSERT INTO `anciano` (`Id_FK`, `dieta_asignada`)
VALUES
(3, TRUE),  -- Carlos González, id=3, tiene una dieta asignada
(6, FALSE), -- Pedro Martínez, id=6, no tiene dieta asignada
(9, TRUE),  -- Fernando Alvarez, id=9, tiene una dieta asignada
(12, TRUE), -- Isabel Reyes, id=12, tiene una dieta asignada
(15, FALSE),  -- Rosa Mendoza, id=15, no tiene dieta asignada
(18, TRUE),   -- Juan Cáceres, id=18, tiene una dieta asignada
(21, FALSE),  -- Manuel Suárez, id=21, no tiene dieta asignada
(24, TRUE),  -- Sara López, id=24, tiene una dieta asignada
(26, FALSE), -- José Mena, id=26, no tiene dieta asignada
(28, TRUE);  -- Gloria Pérez, id=28, tiene una dieta asignada



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
