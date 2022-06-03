-- Creacion de nuestra base de datos

CREATE DATABASE db_grupo1;

-- Nos ubicamos dentro de nuestra Base de Datos

USE db_grupo1;

-- Creamos la tabla usuarios

CREATE TABLE users(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nombre VARCHAR(64) NOT NULL,
	email VARCHAR(64) NOT NULL,
	contrasena VARCHAR(64) NOT NULL
);

-- Creamos la tabla de suscripciones

CREATE TABLE suscriptions(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nombre VARCHAR(64) NOT NULL,
	ciclo VARCHAR(64) NOT NULL,
	precio DECIMAL(8, 2) NOT NULL,
	moneda CHAR(3) NOT NULL,
	fecha_pago DATE NOT NULL
);

-- Ver las tablas de nuestra base de datos
SHOW TABLES;

SELECT * FROM users;

-- Procedimitos almacenados

-- Create
-- Creamos Procedimiento almacenado para insertar usuarios

DELIMITER $$
CREATE PROCEDURE  sp_crear_usuario (
    IN in_nombre VARCHAR(64),
    IN in_email VARCHAR(64),
    IN in_contrasena VARCHAR(64)
)
BEGIN
    IF NOT EXISTS(SELECT email FROM users WHERE email = in_email) THEN
        INSERT INTO users (nombre, email, contrasena) VALUES (in_nombre, in_email, in_contrasena);
    ELSE
        SELECT 'Email ya reguistrado' AS Error;
    END IF;
END $$

-- DROP PROCEDURE sp_crear_usuario;

-- Ejecuatar los procedimientos almacenados
CALL sp_crear_usuario('Kenyi Hancco', 'kenyihq@gmail.com', '123');
CALL sp_crear_usuario('Axel Hancco', 'haxelhq@gmail.com', '321');

-- Read

DELIMITER $$
CREATE PROCEDURE sp_ver_usuarios ()
BEGIN
    SELECT * FROM users;
END $$

-- Ejecutar
CALL sp_ver_usuarios();

-- Update

DELIMITER $$
CREATE PROCEDURE sp_actualizar_usuario(
    IN in_id INT,
    IN in_nombre VARCHAR(64),
    IN in_email VARCHAR(64),
    IN in_contrasena VARCHAR(64)
)
BEGIN
    IF EXISTS(SELECT id FROM users WHERE id = in_id) THEN
        UPDATE users SET nombre = in_nombre, email = in_email, contrasena = in_contrasena
                 WHERE id = in_id;
    ELSE
        SELECT 'ID de usuario no existe' AS Error;
    END IF;
END $$

-- Ejecutar
CALL sp_actualizar_usuario(2, 'Tutankadev', 'tutankadev@gmail.com', '312');

-- Delete
DELIMITER $$
CREATE PROCEDURE sp_eliminar_usuario(
    IN in_id INT
)
BEGIN
    IF EXISTS(SELECT id FROM users WHERE id = in_id) THEN
        DELETE FROM users WHERE id = in_id;
    ELSE
        SELECT 'ID de usuario no existe' AS Error;
    END IF;
END $$

-- Ejecutar
CALL sp_eliminar_usuario(2);

-- Procedimientos almacenados tabla suscripciones


-- Create
-- Creamos Procedimiento almacenado para insertar suscripciones


DELIMITER $$
CREATE PROCEDURE  sp_crear_suscripcion (
	IN in_nombre VARCHAR(64),
	IN in_ciclo VARCHAR(64),
	IN in_precio DECIMAL(8, 2),
	IN in_moneda CHAR(3),
	IN in_fecha_pago DATE
)
BEGIN
	IF NOT EXISTS(SELECT nombre FROM suscriptions WHERE nombre = in_nombre) THEN
		INSERT INTO suscriptions (nombre, ciclo, precio, moneda, fecha_pago) VALUES (in_nombre, in_ciclo, in_precio, in_moneda, in_fecha_pago);
	ELSE
		SELECT 'Nombre de suscripcion ya registrado' AS Error;
	END IF;
END $$


-- DROP PROCEDURE sp_crear_suscripcion;


-- Ejecuatar los procedimientos almacenados
CALL sp_crear_suscripcion('Suscripcion 1', 'Ciclo 1', 10.00, 'USD', '2020-01-01');


-- Read


DELIMITER $$
CREATE PROCEDURE sp_ver_suscripciones ()
BEGIN
	SELECT * FROM suscriptions;
END $$


-- Ejecutar
CALL sp_ver_suscripciones();




-- Update


DELIMITER $$
CREATE PROCEDURE sp_actualizar_suscripcion(
	IN in_id INT,
	IN in_nombre VARCHAR(64),
	IN in_ciclo VARCHAR(64),
	IN in_precio DECIMAL(8, 2),
	IN in_moneda CHAR(3),
	IN in_fecha_pago DATE
)
BEGIN
	IF EXISTS(SELECT id FROM suscriptions WHERE id = in_id) THEN
		UPDATE suscriptions SET nombre = in_nombre, ciclo = in_ciclo, precio = in_precio, moneda = in_moneda, fecha_pago = in_fecha_pago
			WHERE id = in_id;
	ELSE
		SELECT 'ID de suscripcion no existe' AS Error;
	END IF;
END $$


-- Ejecutar
CALL sp_actualizar_suscripcion(1, 'Suscripcion 1', 'Ciclo 1', 10.00, 'USD', '2020-01-01');


-- Delete


DELIMITER $$
CREATE PROCEDURE sp_eliminar_suscripcion(
	IN in_id INT
)
BEGIN
	IF EXISTS(SELECT id FROM suscriptions WHERE id = in_id) THEN
		DELETE FROM suscriptions WHERE id = in_id;
	ELSE
		SELECT 'ID de suscripcion no existe' AS Error;
	END IF;
END $$


-- Ejecutar
CALL sp_eliminar_suscripcion(1);
