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


############################################### NIÑO ###########################################################3



SELECT 
    -- Columna para categoria_edad
    CASE 
        WHEN p.edad_paciente <= 5 THEN 3
        WHEN p.edad_paciente >= 13 THEN 1
        ELSE 2
    END AS categoria_edad,

    -- Columna para IMC_Category
    CASE
        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) < 18.5 THEN 0  -- Se usa 0 para "Fuera de Rango" en la suma
        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 24.9 THEN 1
        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 29.9 THEN 2
        WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 34.9 THEN 3
        ELSE 4
    END AS IMC_Category,

    -- Columna para riesgo_edad
    p.edad_paciente / 100 AS riesgo_edad,

    -- Columna que suma categoria_edad, IMC_Category, y riesgo_edad
    (
        CASE 
            WHEN p.edad_paciente <= 5 THEN 3
            WHEN p.edad_paciente >= 13 THEN 1
            ELSE 2
        END
        +
        CASE
            WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) < 18.5 THEN 0  -- Usamos 0 para "Fuera de Rango" en la suma
            WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 24.9 THEN 1
            WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 29.9 THEN 2
            WHEN (n.peso / ((n.estatura / 100) * (n.estatura / 100))) <= 34.9 THEN 3
            ELSE 4
        END
        +
        p.edad_paciente / 100  -- Se suma riesgo_edad
    ) AS prioridad

FROM patients p
JOIN nino n ON p.id = n.Id_FK  -- Se mantiene el JOIN corregido
WHERE p.grupo_edad = 'niño';


################################################ JOVEN #################################################################

SELECT 
    -- Columna para el cálculo de anos_fumando / 4
    j.anos_fumando / 4 AS anos_fumando_factor,

    -- Columna con factor_edad siempre igual a 2
    2 AS factor_edad,

    -- Columna para el cálculo de riesgo_edad (edad_paciente / 100)
    p.edad_paciente / 100 AS riesgo_edad,

    -- Columna que suma las tres anteriores para calcular Prioridad
    (
        (j.anos_fumando / 4) +
        2 +
        (p.edad_paciente / 100)
    ) AS Prioridad

FROM patients p
JOIN joven j ON p.id = j.Id_FK  -- Relacionar joven con patients
WHERE p.grupo_edad = 'joven';


################################################ ANCIANO #################################################################

SELECT 
    -- Columna 1: Cálculo basado en la dieta y edad
    CASE
        WHEN a.dieta_asignada = 1 AND p.edad_paciente >= 60 
        THEN (p.edad_paciente / 20) + 4
        ELSE (p.edad_paciente / 30) + 3
    END AS resultado_calculo,

    -- Columna 2: Cálculo de (edad_paciente/100) + 5.3
    (p.edad_paciente / 100) + 5.3 AS factor_riesgo,

    -- Columna 3: Suma de las dos columnas anteriores como "Prioridad"
    CASE
        WHEN a.dieta_asignada = 1 AND p.edad_paciente >= 60 
        THEN ((p.edad_paciente / 20) + 4) + ((p.edad_paciente / 100) + 5.3)
        ELSE ((p.edad_paciente / 30) + 3) + ((p.edad_paciente / 100) + 5.3)
    END AS Prioridad
FROM patients p
JOIN anciano a ON p.id = a.Id_FK  -- Relacionar anciano con patients
WHERE p.grupo_edad = 'anciano';
