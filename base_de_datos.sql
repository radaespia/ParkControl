CREATE DATABASE IF NOT EXISTS parkcontrol CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE parkcontrol;

CREATE TABLE usuarios (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 correo VARCHAR(120) NOT NULL UNIQUE,
 clave_hash VARCHAR(255) NOT NULL,
 rol ENUM('ADMINISTRADOR','EMPLEADO') NOT NULL
);
CREATE TABLE vehiculos (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 placa VARCHAR(10) NOT NULL UNIQUE,
 tipo ENUM('CARRO','MOTO') NOT NULL
);
CREATE TABLE espacios (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 codigo VARCHAR(12) NOT NULL UNIQUE,
 tipo_permitido ENUM('CARRO','MOTO') NOT NULL,
 activo BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE TABLE tarifas (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 tipo_vehiculo ENUM('CARRO','MOTO') NOT NULL UNIQUE,
 valor_hora DECIMAL(10,2) NOT NULL
);
CREATE TABLE registros (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 vehiculo_id BIGINT NOT NULL,
 espacio_id BIGINT NOT NULL,
 usuario_entrada_id BIGINT NOT NULL,
 usuario_salida_id BIGINT NULL,
 fecha_entrada DATETIME NOT NULL,
 fecha_salida DATETIME NULL,
 total DECIMAL(10,2) NULL,
 CONSTRAINT fk_reg_veh FOREIGN KEY (vehiculo_id) REFERENCES vehiculos(id),
 CONSTRAINT fk_reg_esp FOREIGN KEY (espacio_id) REFERENCES espacios(id),
 CONSTRAINT fk_reg_ent FOREIGN KEY (usuario_entrada_id) REFERENCES usuarios(id),
 CONSTRAINT fk_reg_sal FOREIGN KEY (usuario_salida_id) REFERENCES usuarios(id),
 CONSTRAINT chk_fechas CHECK (fecha_salida IS NULL OR fecha_salida >= fecha_entrada)
);
CREATE TABLE pagos (
 id BIGINT AUTO_INCREMENT PRIMARY KEY,
 registro_id BIGINT NOT NULL UNIQUE,
 fecha_pago DATETIME NOT NULL,
 monto DECIMAL(10,2) NOT NULL,
 metodo ENUM('EFECTIVO','TRANSFERENCIA') NOT NULL,
 CONSTRAINT fk_pago_reg FOREIGN KEY (registro_id) REFERENCES registros(id)
);

-- Hashes de demostración: no son credenciales de acceso utilizables.
INSERT INTO usuarios (nombre,correo,clave_hash,rol) VALUES
('Administrador Demo','admin@parkcontrol.example','PENDIENTE_HASH_BCRYPT','ADMINISTRADOR'),
('Empleado Demo','empleado@parkcontrol.example','PENDIENTE_HASH_BCRYPT','EMPLEADO');
INSERT INTO vehiculos (placa,tipo) VALUES ('ABC123','CARRO'),('XYZ45A','MOTO'),('DEF456','CARRO');
INSERT INTO espacios (codigo,tipo_permitido) VALUES ('C01','CARRO'),('C02','CARRO'),('M01','MOTO');
INSERT INTO tarifas (tipo_vehiculo,valor_hora) VALUES ('CARRO',4000.00),('MOTO',2000.00);
INSERT INTO registros (vehiculo_id,espacio_id,usuario_entrada_id,usuario_salida_id,fecha_entrada,fecha_salida,total) VALUES
(1,1,2,2,'2026-11-04 08:00:00','2026-11-04 10:00:00',8000.00),
(2,3,2,NULL,'2026-11-04 09:15:00',NULL,NULL);
INSERT INTO pagos (registro_id,fecha_pago,monto,metodo) VALUES
(1,'2026-11-04 10:00:00',8000.00,'EFECTIVO');
-- Reglas de negocio a implementar en Spring Boot: evitar registros activos duplicados
-- por vehículo/espacio, verificar compatibilidad de tipo y calcular cobro
-- redondeando cada fracción de hora hacia arriba según tarifa vigente.
