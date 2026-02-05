-- ============================================
-- VIEW_1 - cobertura por municipios.
-- ============================================
-- Qué devuelve: Resumen de beneficiarios y montos por municipio
-- Grain (qué representa una fila): Un municipio
-- Métricas: SUM y COUNT
-- Por qué usa GROUP BY/HAVING: GROUP BY para poder agrupar por municipio
-- Campos calculado: Monto total entregado
-- ============================================

CREATE OR REPLACE VIEW vw_cobertura_municipio_programa AS
SELECT
    m.nombre AS municipio,
    p.nombre AS programa,
    COUNT(DISTINCT b.id) AS total_beneficiarios,
    COALESCE(SUM(e.monto_entregado), 0) AS monto_total_entregado,
    ROUND((COUNT(DISTINCT b.id)::NUMERIC / NULLIF(m.poblacion_total, 0)) * 100, 2) AS porcentaje_cobertura
FROM municipios m
JOIN beneficiarios b ON m.id = b.id_municipio
JOIN padron_beneficiarios pb ON b.id = pb.id_beneficiario
JOIN programas p ON pb.id_programa = p.id
LEFT JOIN entregas e ON b.id = e.id_beneficiario AND p.id = e.id_programa
GROUP BY m.nombre, p.nombre, m.poblacion_total;

-- ============================================
-- VIEW_2 - Taza aprovacion y rechazo por convocatoria.
-- ============================================
-- Qué devuelve: Resumen de tasa de aprobacion y rechazo por convocatoria
-- Grain (qué representa una fila): Una Convocatoria
-- Métricas: SUM y COUNT
-- Por qué usa GROUP BY/HAVING: Agrupamos por convocatoria y nombre de programa
-- ============================================

--Eficiencia: Tasa de aprobación y rechazo por convocatoria.

CREATE OR REPLACE VIEW vw_taza_aprobacion_rechazo_convocatoria AS
SELECT 
    c.id AS ID_convocatoria,
    p.nombre AS programa,
    COUNT(s.id) AS total_solicitudes,
    SUM(CASE WHEN s.estado = 'Aprobada' THEN 1 ELSE 0 END) AS aprobadas,
    SUM(CASE WHEN s.estado = 'Rechazada' THEN 1 ELSE 0 END) AS rechazadas,
    ROUND(
        (SUM(CASE WHEN s.estado = 'Aprobada' THEN 1 ELSE 0 END)::NUMERIC * 100) / NULLIF(COUNT(s.id), 0), 2
    ) AS tasa_aprobacion
FROM programas p
JOIN convocatorias c ON p.id = c.id_programa
LEFT JOIN solicitudes s ON c.id = s.id_convocatoria
GROUP BY c.id, p.nombre;


-- VIEW 3
-- Nombre del programa, presupuesto anual total, gasto acumulado, porcentaje del presupuesto gastado,
-- presupuesto restante y CASE con 3 opciones: en curso, cerca del limite y sobrepasado

CREATE OR REPLACE VIEW vw_gasto_vs_presupuesto AS
SELECT
    p.nombre AS programa,
    p.presupuesto_anual,
    COALESCE(SUM(e.monto_entregado), 0) AS gasto_anual_actual,
    ROUND(COALESCE(SUM(e.monto_entregado), 0) / NULLIF(p.presupuesto_anual, 0) * 100,2) AS porcentaje_gastado,
    p.presupuesto_anual - COALESCE(SUM(e.monto_entregado), 0) AS saldo,
    CASE
        WHEN COALESCE(SUM(e.monto_entregado), 0) / NULLIF(p.presupuesto_anual, 0) * 100 <= 70 THEN 'En curso'
        WHEN COALESCE(SUM(e.monto_entregado), 0) / NULLIF(p.presupuesto_anual, 0) * 100 BETWEEN 70 AND 100 THEN 'Cerca del limite'
        ELSE 'Sobrepasado'
    END AS clasificacion
FROM programas p
LEFT JOIN entregas e ON p.id = e.id_programa
    AND e.fecha_entrega >= DATE '2026-01-01'
    AND e.fecha_entrega < DATE '2027-01-01'
GROUP BY p.id, p.nombre, p.presupuesto_anual
ORDER BY porcentaje_gastado DESC;

-- ============================================
-- VIEW_4 - beneficiarios con múltiples programas activos
-- ============================================
-- Qué devuelve: Beneficiarios que están activos simultáneamente en más
--               de un programa social, junto con el monto total recibido.
-- Grain (qué representa una fila): Un beneficiario.
-- Métricas: COUNT(DISTINCT programas), SUM(monto_entregado).
-- Por qué usa GROUP BY/HAVING: GROUP BY para agrupar por beneficiario
--                              y HAVING para filtrar solo aquellos con
--                              más de un programa activo.
-- Campos calculados: Total de programas activos y monto total recibido.
-- Consideraciones: Usa COALESCE para manejar beneficiarios sin entregas.
-- ============================================
CREATE VIEW vw_beneficiarios_multiplos_programas AS
SELECT
    b.id AS beneficiario_id,
    b.curp,
    b.nombre,
    b.apellido_paterno,

    COUNT(DISTINCT pb.programa_id) AS total_programas_activos,
    COALESCE(SUM(e.monto_entregado), 0) AS monto_total_recibido

FROM beneficiarios b
JOIN padron_beneficiarios pb
    ON pb.beneficiario_id = b.id
    AND pb.estatus_padrón = 'Activo'
LEFT JOIN entregas e
    ON e.beneficiario_id = b.id
    AND e.programa_id = pb.programa_id

GROUP BY
    b.id,
    b.curp,
    b.nombre,
    b.apellido_paterno

HAVING COUNT(DISTINCT pb.programa_id) > 1;


-- ============================================
-- VIEW_5 - bitácora de rechazos recientes
-- ============================================
-- Qué devuelve: Listado de solicitudes rechazadas en los últimos 90 días
--               incluyendo datos del beneficiario y el motivo del rechazo.
-- Grain (qué representa una fila): Un evento de rechazo de una solicitud.
-- Métricas: No aplica (consulta de detalle).
-- Por qué usa GROUP BY/HAVING: No usa GROUP BY porque no agrega datos,
--                              muestra eventos individuales.
-- Campos calculados: Motivo del rechazo con valor por defecto
--                    'Sin motivo registrado'.
-- Consideraciones: Usa COALESCE para manejar rechazos sin motivo capturado.
-- ============================================

CREATE VIEW vw_rechazos_recientes AS
SELECT
    s.id AS solicitud_id,
    b.curp,
    b.nombre,
    be.fecha_cambio AS fecha_rechazo,
    COALESCE(be.motivo, 'Sin motivo registrado') AS motivo_rechazo

FROM bitacora_estados be
JOIN solicitudes s
    ON s.id = be.solicitud_id
JOIN beneficiarios b
    ON b.id = s.beneficiario_id

WHERE
    be.estado_nuevo = 'Rechazada'
    AND be.fecha_cambio >= CURRENT_DATE - INTERVAL '90 days';
