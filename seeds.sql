-- Semillas de prueba
-- Orden de ejecución: schema -> seeds -> views

-- 1. Municipios
INSERT INTO municipios (nombre, poblacion_total) VALUES
('Chamula', 100000),
('San Cristobal', 250000),
('Tuxtla Gutierrez', 600000);

-- 2. Programas
INSERT INTO programas (nombre, descripcion, presupuesto_anual, monto_apoyo, periodicidad) VALUES
('Becas Futuro', 'Apoyo a estudiantes', 1000000.00, 2500.00, 'Mensual'),
('Sembrando Vida', 'Apoyo al campo', 5000000.00, 5000.00, 'Mensual');

-- 3. Evaluadores
INSERT INTO evaluadores (nombre, cargo) VALUES
('Lic. Pérez', 'Supervisor'),
('Ing. Gómez', 'Auditor');

-- 4. Convocatorias
INSERT INTO convocatorias (id_programa, periodo, fecha_inicio, fecha_fin, cupo_maximo, requisitos_elegibilidad) VALUES
(1, '2026-A', '2026-01-01', '2026-01-31', 1000, 'Ser estudiante activo');

-- 5. Beneficiarios
INSERT INTO beneficiarios (curp, nombre, apellido_paterno, apellido_materno, email, id_municipio) VALUES
('CURP00000000000001', 'Juan', 'Perez', 'Lopez', 'juan@example.com', 1),
('CURP00000000000002', 'Maria', 'Gomez', 'Diaz', 'maria@example.com', 1),
('CURP00000000000003', 'Pedro', 'Hernandez', 'Ruiz', 'pedro@example.com', 2),
('CURP00000000000004', 'Ana', 'Martinez', 'Solis', 'ana@example.com', 2),
('CURP00000000000005', 'Luisa', 'Torres', 'Mendez', 'luisa@example.com', 3);

-- 6. Padrón (Inscribir a programas)
INSERT INTO padron_beneficiarios (id_beneficiario, id_programa, fecha_alta, estatus_padron) VALUES
(1, 1, '2026-02-01', 'Activo'),
(2, 1, '2026-02-01', 'Activo'),
(3, 2, '2026-02-01', 'Activo'),
(4, 2, '2026-02-01', 'Activo');

-- 7. Entregas (Realizar pagos)
INSERT INTO entregas (id_beneficiario, id_programa, fecha_entrega, metodo_entrega, monto_entregado) VALUES
(1, 1, '2026-02-15', 'Transferencia', 2500.00), -- Juan, Becas
(2, 1, '2026-02-15', 'Transferencia', 2500.00), -- Maria, Becas
(3, 2, '2026-02-15', 'Especie', 5000.00);      -- Pedro, Sembrando
