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
    `fecha_ingreso_consulta` DATETIME NOT NULL DEFAULT NOW(), -- Fecha y hora automáticas
    `hora_ingreso_consulta` TIME GENERATED ALWAYS AS (CAST(`fecha_ingreso_consulta` AS TIME)), -- Extraer hora de la fecha
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

