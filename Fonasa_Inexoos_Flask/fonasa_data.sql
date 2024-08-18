-- Primero, eliminamos el trigger existente
DROP TRIGGER IF EXISTS `verify_anciano`;

-- Crear el nuevo trigger para verificar que solo se insertan pacientes del grupo 'anciano' y con edad > 40
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

    -- Verificar si el paciente pertenece al grupo 'anciano' y su edad es mayor a 40
    IF grupo != 'anciano' OR edad <= 40 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El paciente no pertenece al grupo de edad anciano o no tiene la edad mínima de 41 años.';
    END IF;
END //

DELIMITER ;

-- Alterar la tabla `estado_paciente` antes de comenzar la transacción
-- Primero agregamos la nueva columna Id_FK_Hospital
ALTER TABLE `estado_paciente`
ADD COLUMN `Id_FK_Hospital` int(11) NOT NULL;

-- Luego agregamos la restricción de clave foránea para que Id_FK_Hospital haga referencia a la tabla hospital
ALTER TABLE `estado_paciente`
ADD CONSTRAINT `fk_hospital_estado_paciente`
FOREIGN KEY (`Id_FK_Hospital`) REFERENCES `hospital`(`Id_PK_Hospital`);

-- Ahora comenzamos la transacción
START TRANSACTION;

-- Insertar más datos en la tabla `anciano`
INSERT INTO `anciano` (`Id_FK`, `dieta_asignada`)
VALUES
(57, TRUE),
(60, FALSE),
(63, TRUE),
(66, TRUE),
(69, FALSE),
(72, TRUE),
(75, FALSE),
(79, TRUE),
(80, FALSE),
(81, TRUE);

-- Confirmar la transacción si todo ha salido bien
COMMIT;


SELECT 
    p.id, 
    p.nombre_paciente, 
    p.apellido_paciente, 
    p.edad_paciente, 
    p.grupo_edad, 
    n.estatura, 
    n.peso
FROM 
    patients p
JOIN 
    nino n 
ON 
    p.id = n.Id_FK
WHERE 
    p.grupo_edad = 'niño';

########################################

SELECT 
    p.id, 
    p.nombre_paciente, 
    p.apellido_paciente, 
    p.edad_paciente, 
    p.grupo_edad, 
    j.fumador, 
    j.anos_fumando
FROM 
    patients p
JOIN 
    joven j 
ON 
    p.id = j.Id_FK
WHERE 
    p.grupo_edad = 'joven';

#######################################

SELECT 
    p.id, 
    p.nombre_paciente, 
    p.apellido_paciente, 
    p.edad_paciente, 
    p.grupo_edad, 
    a.dieta_asignada
FROM 
    patients p
JOIN 
    anciano a 
ON 
    p.id = a.Id_FK
WHERE 
    p.grupo_edad = 'anciano';
