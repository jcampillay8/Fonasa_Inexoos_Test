ALTER TABLE `estado_paciente`
ADD COLUMN `fecha_ingreso_consulta` DATE NOT NULL DEFAULT (CURRENT_DATE) AFTER `Estado_Consulta`,
ADD COLUMN `hora_ingreso_consulta` TIME NOT NULL DEFAULT (CURRENT_TIME) AFTER `fecha_ingreso_consulta`;
