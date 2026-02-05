-- ============================================
-- VIEW_1 - cobertura por municipios.
-- ============================================
-- Qué devuelve: Resumen de beneficiarios y montos por municipio
-- Grain (qué representa una fila): Un municipio
-- Métricas: SUM y COUNT
-- Por qué usa GROUP BY/HAVING: GROUP BY para poder agrupar por grupo
-- Campos calculados: pormedio de asistencia
-- ============================================

CREATE OR REPLACE VIEW vista_cobertura_municipio_programa AS
SELECT
    m.nombre AS municipio,
    p.nombre AS programa,
    COUNT(DISTINCT b.id_beneficiario) AS total_beneficiarios,
    COALESCE(SUM(e.monto_entregado), 0) AS monto_total_entregado
FROM municipios m
JOIN beneficiarios b ON m.id_municipio = b.id_municipio
JOIN padron_beneficiarios pb ON b.id_beneficiario = pb.id_beneficiario
JOIN programas p ON pb.id_programa = p.id_programa
LEFT JOIN entregas e ON b.id_beneficiario = e.id_beneficiario AND p.id_programa = e.id_programa
GROUP BY m.nombre, p.nombre
ORDER BY m.nombre, p.nombre;


-- VIEW 3
-- Nombre del programa, presupuesto anual total, gasto acumulado, porcentaje del presupuesto gastado,
-- presupuesto restante y CASE con 3 opciones: en curso, cerca del limite y sobrepasado

SELECT
    p.nombre AS programa,
    p.presupuesto_anual AS presupuesto total,