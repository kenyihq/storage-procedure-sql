-- Creacion de nuestra base de datos

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
	contrasena VARCHAR(64) NOT NULL
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

-- Verificamos que esten todas nuestras tablas

SELECT * FROM INFORMATION_SCHEMA.TABLES
GO

SELECT * FROM users
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

CREATE PROCEDURE sp_ver_usuarios
AS
BEGIN
	SELECT * FROM users
END
GO

EXEC sp_ver_usuarios
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
EXEC sp_actualizar_usuario 1, 'Tutankadev', 'tutankadev@gmai.com', '321'
GO
-- Prueba de error
EXEC sp_actualizar_usuario 5, 'Tutankadev', 'tutankadev@gmai.com', '321'
GO

-- Delete

CREATE PROCEDURE sp_eliminar_usario
	@id INT
AS
	BEGIN
		IF EXISTS(SELECT id FROM users WHERE id = @id)
			DELETE users WHERE id = @id
		ELSE
			RAISERROR('ID de usuario no existe', 16, 1)
			WITH NOWAIT
	END
GO

EXEC sp_eliminar_usario 4
GO