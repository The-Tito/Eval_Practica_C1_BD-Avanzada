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
-- Por qué usa GROUP BY/HAVING: GROUP BY para poder agrupar por municipio
-- Campos calculado: Monto total entregado
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

SELECT
    p.nombre AS programa,
    p.presupuesto_anual AS presupuesto_total
FROM programas p; -- View in construction