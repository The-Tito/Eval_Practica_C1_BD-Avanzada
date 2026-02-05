-- 1. Tablas Maestras (Independientes)
CREATE TABLE municipios (
    id_municipio SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE, -- Ej. 'Chamula'
    poblacion_total INT CHECK (poblacion_total > 0) -- Para calcular % de cobertura
);

CREATE TABLE programas (
    id_programa SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE, -- Ej. 'Becas Futuro'
    descripcion TEXT,
    presupuesto_anual DECIMAL(15,2) NOT NULL CHECK (presupuesto_anual > 0), -- Requerido para reporte de gasto
    monto_apoyo DECIMAL(10,2) CHECK (monto_apoyo >= 0), -- Apoyo monetario base
    periodicidad VARCHAR(20) CHECK (periodicidad IN ('Mensual', 'Bimestral', 'Trimestral', 'Semestral', 'Anual')) -- 'Bimestral', 'Mensual'
);

CREATE TABLE evaluadores (
    id_evaluador SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL, -- Ej. 'Lic. Pérez'
    cargo VARCHAR(50)
);

-- 2. Tablas con Dependencias Simples
CREATE TABLE beneficiarios (
    id_beneficiario SERIAL PRIMARY KEY,
    curp CHAR(18) UNIQUE NOT NULL CHECK (LENGTH(curp) = 18), -- Identificador unívoco, debe tener 18 caracteres
    nombre VARCHAR(50) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50),
    fecha_nacimiento DATE,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(15),
    id_municipio INT REFERENCES municipios(id_municipio)
);

CREATE TABLE convocatorias (
    id_convocatoria SERIAL PRIMARY KEY,
    id_programa INT REFERENCES programas(id_programa),
    periodo VARCHAR(10), -- Ej. '2026-A'
    fecha_inicio DATE,
    fecha_fin DATE,
    cupo_maximo INT NOT NULL CHECK (cupo_maximo > 0),
    requisitos_elegibilidad TEXT,
    CONSTRAINT chk_fechas_convocatoria CHECK (fecha_fin >= fecha_inicio)
);

-- 3. Gestión de Solicitudes y Padrón
CREATE TABLE solicitudes (
    id_solicitud SERIAL PRIMARY KEY,
    id_beneficiario INT REFERENCES beneficiarios(id_beneficiario),
    id_convocatoria INT REFERENCES convocatorias(id_convocatoria),
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) CHECK (estado IN ('Recibida', 'En revisión', 'Aprobada', 'Rechazada')), -- 'Recibida', 'En revisión', 'Aprobada', 'Rechazada'
    id_evaluador_asignado INT REFERENCES evaluadores(id_evaluador)
);

CREATE TABLE bitacora_estados (
    id_bitacora SERIAL PRIMARY KEY,
    id_solicitud INT REFERENCES solicitudes(id_solicitud),
    estado_anterior VARCHAR(20) CHECK (estado_anterior IN ('Recibida', 'En revisión', 'Aprobada', 'Rechazada')),
    estado_nuevo VARCHAR(20) CHECK (estado_nuevo IN ('Recibida', 'En revisión', 'Aprobada', 'Rechazada')),
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_usuario_cambio INT REFERENCES evaluadores(id_evaluador),
    motivo TEXT -- Para capturar por qué se rechazó o cambió
);

CREATE TABLE padron_beneficiarios (
    id_padron SERIAL PRIMARY KEY,
    id_beneficiario INT REFERENCES beneficiarios(id_beneficiario),
    id_programa INT REFERENCES programas(id_programa),
    fecha_alta DATE NOT NULL,
    fecha_baja DATE NULL,
    motivo_baja VARCHAR(255) NULL, -- Ej. 'Fallecimiento'
    estatus_padron VARCHAR(20) CHECK (estatus_padron IN ('Activo', 'Baja')), -- 'Activo', 'Baja'
    CONSTRAINT chk_fechas_padron CHECK (fecha_baja IS NULL OR fecha_baja >= fecha_alta)
);

-- 4. Registro de Entregas y Apoyos en Especie
CREATE TABLE entregas (
    id_entrega SERIAL PRIMARY KEY,
    id_beneficiario INT REFERENCES beneficiarios(id_beneficiario),
    id_programa INT REFERENCES programas(id_programa),
    fecha_entrega DATE,
    metodo_entrega VARCHAR(20) CHECK (metodo_entrega IN ('Transferencia', 'Especie')), -- 'Transferencia', 'Especie'
    monto_entregado DECIMAL(10,2) DEFAULT 0 CHECK (monto_entregado >= 0)
);

CREATE TABLE entregas_especie (
    id_especie SERIAL PRIMARY KEY,
    id_entrega INT REFERENCES entregas(id_entrega),
    descripcion_producto VARCHAR(255), -- Ej. 'Semillas y fertilizante'
    cantidad INT CHECK (cantidad > 0)
);