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

SELECT * FROM users
GO

-- Ejecucion correctamente
EXEC sp_actualizar_usuario 1, 'Tutankadev', 'tutankadev@gmai.com', '321'
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
			IF (SELECT estado FROM users WHERE estado = 0 AND id = @id) = 0
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

SELECT * FROM users
GO

EXEC sp_todos_usuarios
GO

EXEC sp_cambio_estado 2
GO

EXEC sp_todos_usuarios
GO

EXEC sp_usuarios_activos
EXEC sp_usuarios_de_baja
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

SELECT * FROM suscriptions
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
SELECT * FROM suscriptions
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
EXEC sp_suscripciones_por_usuario 2
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
EXEC sp_actualizar_sus 7, 'Netflix', 'Mensual', 24.90, 'PEN', '2022-06-04'
GO

SELECT * FROM suscriptions
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

EXEC sp_delete_sus 30
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

EXEC sp_suscripciones_por_usuario 12
GO

EXEC sp_actualizar_sus 1, 'Netflix', 'Mensual', 24.90, 'PEN', '2022-06-04'
GO

-- FTR5
--Consultas estadisticas


-- Mostramos todos los usuarios
EXEC sp_todos_usuarios
GO


-- Mostramos todas las suscripciones con sus respectivos usuarios
SELECT * FROM vw_ver_suscripciones
GO


EXEC sp_suscripciones_por_usuario 1
GO

--Creamos nuvos procedimientos almacenados

CREATE PROCEDURE sp_busqueda_moneda
	@id INT,
	@moneda CHAR(3)
AS
BEGIN
	IF EXISTS(SELECT id FROM users WHERE id = @id)
	BEGIN
		SELECT
			u.nombre Usuario,
			u.email Email,
			s.nombre Plataforma,
			s.moneda Moneda,
			s.precio Precio,
			s.ciclo Ciclo,
			s.fecha_pago 'Fecha de pago'
		FROM suscriptions s
		INNER JOIN users U ON u.id = @id AND s.moneda = @moneda
		WHERE s.id_user = u.id
	END
	ELSE
		RAISERROR('ID no existe', 16, 2)
		WITH NOWAIT
END

-- Ejecutamos nuestro procedimiento almacenado para la busqueda
EXEC sp_busqueda_moneda 1, 'PEN'
GO

-- Consulta para busqueda por tipo de moneda
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON u.id = 2 AND s.moneda = 'PEN'
WHERE s.id_user = u.id
GO

--Creamos Procedimiento almacenado para la busqueda por plataforma
CREATE PROCEDURE sp_busqueda_plataforma
	@plataforma VARCHAR(64)
AS
BEGIN
	IF EXISTS(SELECT nombre FROM suscriptions WHERE nombre = @plataforma)
	BEGIN
		SELECT
			s.nombre Plataforma,
			u.nombre Usuario,
			u.email Email,
			s.moneda Moneda,
			s.precio Precio,
			s.ciclo Ciclo,
			s.fecha_pago 'Fecha de pago'
		FROM suscriptions s
		INNER JOIN users u ON s.nombre = @plataforma
		WHERE s.id_user = u.id
	END
	ELSE
		RAISERROR('Plataforma no existe', 16, 2)
		WITH NOWAIT
END

--Ejecutamos
EXEC sp_busqueda_plataforma 'Spotify'
GO

-- Coculta para busqueda por pltaforma
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON s.nombre = 'Deezer'
WHERE s.id_user = u.id
GO

--Creamos Procedimiento almacenado para la busqueda por ciclo de pago
CREATE PROCEDURE sp_busqueda_ciclo
	@ciclo VARCHAR(64)
AS
BEGIN
	IF EXISTS(SELECT ciclo FROM suscriptions WHERE ciclo = @ciclo)
	BEGIN
		SELECT
			s.ciclo Ciclo,
			s.nombre Plataforma,
			u.nombre Usuario,
			u.email Email,
			s.moneda Moneda,
			s.precio Precio,
			s.fecha_pago 'Fecha de pago'
		FROM suscriptions s
		INNER JOIN users u ON s.ciclo = @ciclo
		WHERE s.id_user = u.id
	END
	ELSE
		RAISERROR('Ciclo no existe', 16, 2)
		WITH NOWAIT
END

--Ejecutamos
EXEC sp_busqueda_ciclo 'Semanal'
GO

-- Coculta para busqueda por ciclo de pago
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON s.ciclo = 'Anual'
WHERE s.id_user = u.id
GO

--Creamos Procedimiento almacenado para la busqueda por ciclo de pago y plataforma
CREATE PROCEDURE sp_busqueda_ciclo_plataforma
	@ciclo VARCHAR(64),
	@plataforma VARCHAR(64)
AS
BEGIN
	IF EXISTS(SELECT nombre FROM suscriptions WHERE nombre = @plataforma)
	BEGIN
		SELECT
			s.nombre Plataforma,
			s.ciclo Ciclo,
			u.nombre Usuario,
			u.email Email,
			s.moneda Moneda,
			s.precio Precio,
			s.fecha_pago 'Fecha de pago'
		FROM suscriptions s
		INNER JOIN users u ON s.ciclo = @ciclo AND s.nombre = @plataforma
		WHERE s.id_user = u.id
	END
	ELSE
		RAISERROR('Ciclo no existe', 16, 2)
		WITH NOWAIT
END

--Ejecutamos
EXEC sp_busqueda_ciclo_plataforma 'Mensual', 'Netflix'
GO

-- Cosulta para busqueda por ciclo de pago y plataforma
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON s.ciclo = 'Anual' AND s.nombre = 'Spotify'
WHERE s.id_user = u.id
GO


--Creamos Procedimiento almacenado para la busqueda por ciclo de pago y plataforma
CREATE PROCEDURE sp_busqueda_ciclo_plataforma_moneda
	@ciclo VARCHAR(64),
	@plataforma VARCHAR(64),
	@moneda CHAR(3)
AS
BEGIN
	IF EXISTS(SELECT nombre FROM suscriptions WHERE nombre = @plataforma)
	BEGIN
		SELECT
			s.nombre Plataforma,
			s.ciclo Ciclo,
			s.moneda Moneda,
			u.nombre Usuario,
			u.email Email,
			s.precio Precio,
			s.fecha_pago 'Fecha de pago'
		FROM suscriptions s
		INNER JOIN users u ON s.ciclo = @ciclo AND s.nombre = @plataforma AND s.moneda = @moneda
		WHERE s.id_user = u.id
	END
	ELSE
		RAISERROR('Ciclo no existe', 16, 2)
		WITH NOWAIT
END

--Ejecutamos
EXEC sp_busqueda_ciclo_plataforma 'Mensual', 'Netflix'
GO

-- Cosulta para busqueda por ciclo de pago, plataforma y moneda
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON s.ciclo = 'Anual' AND s.nombre = 'Spotify' AND s.moneda = 'CNY'
WHERE s.id_user = u.id
GO

-- Cosulta para busqueda por rango de fecha
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON s.ciclo = 'Semestral' AND s.nombre = 'Spotify'
WHERE s.id_user = u.id
GO

-- Consulta para saber fecha de pago y la cantidad de usuarios
SELECT CAST(fecha_pago AS Date) AS dia, COUNT(id) AS total FROM suscriptions 
GROUP BY CAST(fecha_pago AS Date)

-- Cosulta para busqueda por rango de fecha
SELECT DISTINCT * FROM suscriptions s
INNER JOIN users U ON s.fecha_pago BETWEEN '2022-06-01' AND '2022-12-30'
WHERE s.id_user = u.id
GO

-- Clientes antiguos con descuentos
SELECT DISTINCT 
	u.nombre Nombre,
	u.email Email,
	s.nombre Plataforma,
	s.precio 'Precio total',
	CONVERT(DECIMAL(8, 2), s.precio*0.1) 'Descuento',
	CONVERT(DECIMAL(8, 2), s.precio - s.precio*0.1) 'Precio a pagar',
	s.ciclo Ciclo,
	s.fecha_pago 'Fecha de pago'
FROM suscriptions s
INNER JOIN 
	users U ON s.fecha_pago BETWEEN '2022-06-01' AND '2022-06-30'
WHERE s.id_user = u.id
GO


-- Sumatoria

CREATE VIEW vw_total
AS
SELECT DISTINCT 
		u.nombre Nombre,
		u.email Email,
		s.nombre Plataforma,
		s.precio 'Precio total',
		CONVERT(DECIMAL(8, 2), s.precio*0.1) 'Descuento',
		CONVERT(DECIMAL(8, 2), s.precio - s.precio*0.1) Total,
		s.ciclo Ciclo,
		s.fecha_pago 'Fecha de pago'
	FROM suscriptions s
	INNER JOIN 
		users U ON s.fecha_pago BETWEEN '2022-06-01' AND '2022-06-30'
	WHERE s.id_user = u.id
GO

SELECT
	SUM(Total) 'A pagar',
	SUM(Descuento) 'Total descuento',
	SUM(Total)-SUM(Descuento) 'Total a cobrar'
FROM vw_total
GO