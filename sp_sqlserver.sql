-- Creacion de nuestra base de datos
USE master

DROP DATABASE db_grupo1
GO

CREATE DATABASE db_grupo1
GO

-- Nos ubicamos dentro de nuestra Base de Datos

USE db_grupo1
GO

-- Creamos la tabla usuarios

CREATE TABLE users(
	id INT PRIMARY KEY IDENTITY(1 ,1) NOT NULL,
	nombre VARCHAR(64) NOT NULL,
	email VARCHAR(64) NOT NULL,
	contrasena VARCHAR(64) NOT NULL,
	estado BIT DEFAULT 1
)
GO

-- Creamos la tabla de suscripciones

CREATE TABLE suscriptions(
	id INT PRIMARY KEY IDENTITY(1, 1) NOT NULL,
	nombre VARCHAR(64) NOT NULL,
	ciclo VARCHAR(64) NOT NULL,
	precio DECIMAL(8, 2) NOT NULL,
	moneda CHAR(3) NOT NULL,
	fecha_pago DATE NOT NULL
)
GO

-- Agregamos un allave foraenea para relacionar la tabla de suscripciones con las de usuarios
ALTER TABLE suscriptions
ADD id_user INT NOT NULL CONSTRAINT fk_user FOREIGN KEY (id_user) REFERENCES users (id)
GO


-- Verificamos que esten todas nuestras tablas

SELECT * FROM INFORMATION_SCHEMA.TABLES
GO

SELECT * FROM users
GO

SELECT * FROM suscriptions
GO

-- Procedimitos almacenados

-- Creat
-- Creamos Procedimiento almacenado para insertar usuarios

CREATE PROCEDURE sp_insertar_usuarios
	@nombre VARCHAR(64),
	@email VARCHAR(64),
	@contrasena VARCHAR(64)
AS
BEGIN
	IF NOT EXISTS(SELECT email FROM users WHERE email = @email)
		BEGIN
		INSERT INTO users (
			nombre,
			email,
			contrasena
			) VALUES (
			@nombre,
			@email,
			@contrasena
			)
		END
	ELSE
		BEGIN
			RAISERROR('Email ya existe', 16, 1)
			WITH NOWAIT
		END
END
GO

EXEC sp_insertar_usuarios 'Kenyi Hancco', 'kenyihq@gmail.com', '123'
GO
EXEC sp_insertar_usuarios 'Robinson Thomas', 'robinsont@gmail.com', '123'
GO
EXEC sp_insertar_usuarios 'Joaquin Huarilloclla', 'eduardoqueria@gmail.com', '1234'
GO
EXEC sp_insertar_usuarios 'Joaquin Huarilloclla', 'eduardoqueria@hotmail.com', '1234'
GO


-- Read
-- Ver todos los usuarios
CREATE PROCEDURE sp_todos_usuarios
AS
BEGIN
	SELECT id ID, nombre Nombre, email Email,
	CASE estado
		WHEN 1 THEN 'Activo'
		WHEN 0 THEN 'De baja'
		END AS Estado
	FROM users
END
GO

-- Ejecutar
EXEC sp_todos_usuarios
GO

CREATE PROCEDURE sp_usuarios_activos
AS
BEGIN
	SELECT id ID, nombre Nombre, email Email,
	CASE estado
		WHEN 1 THEN 'Activo'
		WHEN 0 THEN 'De baja'
		END AS Estado
	FROM users
	WHERE estado = 1
END
GO

EXEC sp_usuarios_activos
GO

CREATE PROCEDURE sp_usuarios_de_baja
AS
BEGIN
	SELECT id ID, nombre Nombre, email Email,
	CASE estado
		WHEN 1 THEN 'Activo'
		WHEN 0 THEN 'De baja'
		END AS Estado
	FROM users
	WHERE estado = 0
END
GO

EXEC sp_usuarios_de_baja
GO


-- Update

CREATE PROCEDURE sp_actualizar_usuario
	@id INT,
	@nombre VARCHAR(64),
	@email VARCHAR(64),
	@contrasena VARCHAR(64)
AS
BEGIN
	IF EXISTS(SELECT id FROM users WHERE id = @id)
		BEGIN
			UPDATE users SET nombre = @nombre, email = @email, contrasena = @contrasena
			WHERE id = @id
		END
	ELSE
		BEGIN
			RAISERROR('ID usuario no existe', 16, 1)
			WITH NOWAIT
		END
END
GO

-- Ejecucion correctamente
EXEC sp_actualizar_usuario 61, 'Tutankadev', 'tutankadev@gmai.com', '321'
GO
-- Prueba de error
EXEC sp_actualizar_usuario 5, 'Tutankadev', 'tutankadev@gmai.com', '321'
GO

-- Delete

CREATE PROCEDURE sp_cambio_estado
	@id INT
AS
	BEGIN
		IF EXISTS(SELECT id FROM users WHERE id = @id)
			BEGIN
			IF (SELECT estado FROM users WHERE estado = 0) = 0
				UPDATE users SET estado = 1
				WHERE id = @id
			
			ELSE
				UPDATE users SET estado = 0
				WHERE id = @id
			END		
		ELSE
			RAISERROR('ID de usuario no existe', 16, 1)
			WITH NOWAIT
	END
GO


EXEC sp_cambio_estado 3
GO

EXEC sp_todos_usuarios
GO

-- Procedimientos almacenados para suscripciones
SELECT * FROM suscriptions
GO
-- CREATE

CREATE PROCEDURE sp_insertar_sus
	@nombre VARCHAR(64),
	@ciclo  VARCHAR(64),
	@precio DECIMAL(8, 2),
	@moneda  CHAR(3),
	@fecha_pago DATE,
	@id_user INT
AS
BEGIN
	IF NOT EXISTS (SELECT nombre FROM suscriptions WHERE nombre = @nombre AND id_user = @id_user)
	BEGIN
		INSERT INTO suscriptions (
			nombre,
			ciclo,
			precio,
			moneda,
			fecha_pago,
			id_user
		) VALUES (
			@nombre,
			@ciclo,
			@precio,
			@moneda,
			@fecha_pago,
			@id_user
		)	
	END
	ELSE
	BEGIN
		RAISERROR('Suscripción ya existe', 16, 1)
		WITH NOWAIT
	END
END
GO

--DROP PROCEDURE sp_insertar_sus
--GO

-- Ejecutar
EXEC sp_insertar_sus 'Netflix', 'Mensual', 44.90, 'PEN', '2022-06-03', 1
GO
EXEC sp_insertar_sus 'Netflix', 'Mensual', 44.90, 'PEN', '2022-06-03', 2
EXEC sp_insertar_sus 'Spotify', 'Mensual', 9.90, 'PEN', '2022-06-03', 1
EXEC sp_insertar_sus 'Amazon Prime', 'Mensual', 24.90, 'PEN', '2022-06-03', 1
GO

-- READ

CREATE VIEW vw_ver_suscripciones
AS
SELECT 
	su.nombre AS Plataforma,
	su.precio AS Precio,
	su.moneda AS Moneda,
	su.fecha_pago AS 'Fecha de pago',
	us.nombre AS Usuario
FROM
	suscriptions su,
	users us 
WHERE us.id = su.id_user
GO

--DROP VIEW vw_ver_suscripciones
--GO

-- Ejecutar la vista
SELECT * FROM vw_ver_suscripciones
GO

-- Procedimiento almacenado para ver suscripciones por usuario
CREATE PROCEDURE sp_suscripciones_por_usuario
	@id INT
AS
BEGIN
	IF EXISTS (SELECT id FROM users WHERE id = @id)
	BEGIN
		SELECT DISTINCT
			su.nombre AS Plataforma,
			su.precio AS Precio,
			su.moneda AS Moneda,
			su.fecha_pago AS 'Fecha de pago',
			us.nombre AS Usuario
		FROM
			suscriptions su,
			users us
		INNER JOIN users ON us.id = @id
		WHERE us.id = su.id_user
	END
	ELSE
		RAISERROR('Id de usuario no existe', 16, 1)
		WITH NOWAIT
END
GO

--DROP PROCEDURE sp_suscripciones_por_usuario

-- Ejecutar
EXEC sp_suscripciones_por_usuario 3
GO

-- UPDATE
SELECT * FROM suscriptions
GO
CREATE PROCEDURE sp_actualizar_sus
	@id INT,
	@nombre VARCHAR(64),
	@ciclo VARCHAR(64),
	@precio DECIMAL(8, 2),
	@moneda CHAR(3),
	@fecha_pago DATE
AS
BEGIN
	IF EXISTS(SELECT id FROM suscriptions WHERE id = @id)
		BEGIN
			UPDATE suscriptions SET
				nombre = @nombre,
				ciclo = @ciclo,
				precio = @precio,
				moneda = @moneda,
				fecha_pago = @fecha_pago
			WHERE id = @id
		END
	ELSE
		BEGIN
			RAISERROR('Id de la suscripción  no existe', 16, 1)
			WITH NOWAIT
		END
END
GO

-- Ejecutar
EXEC sp_actualizar_sus 1, 'Netflix', 'Mensual', 44.90, 'PEN', '2022-06-04'
GO

-- DELETE
CREATE PROCEDURE sp_delete_sus
	@id INT
AS
BEGIN
	IF EXISTS(SELECT id FROM suscriptions WHERE id = @id)
		BEGIN
			DELETE FROM suscriptions WHERE id = @id
		END
	ELSE
		BEGIN
			RAISERROR('Id del usuario no existe', 16, 1)
			WITH NOWAIT
		END
END
GO

EXEC sp_delete_sus 3
GO


-- Consultas
EXEC sp_todos_usuarios
GO

EXEC sp_cambio_estado 2
GO


EXEC sp_usuarios_activos
GO

EXEC sp_usuarios_de_baja
GO

EXEC sp_actualizar_usuario 1, 'Tutankadev', 'tutankadev@gmai.com', '321'
GO

EXEC sp_cambio_estado 1
GO

EXEC sp_insertar_sus 'Platzi', 'Mensual', 44.90, 'PEN', '2022-06-03', 1
GO

SELECT * FROM vw_ver_suscripciones
GO

EXEC sp_suscripciones_por_usuario 1
GO

EXEC sp_actualizar_sus 1, 'Netflix', 'Mensual', 24.90, 'PEN', '2022-06-04'
GO

