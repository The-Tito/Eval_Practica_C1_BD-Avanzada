


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
LEFT JOIN entregas e ON p.id_programa = e.id_programa
    AND e.fecha_entrega >= DATE '2026-01-01'
    AND e.fecha_entrega < DATE '2027-01-01'
GROUP BY p.id_programa, p.nombre, p.presupuesto_anual
ORDER BY porcentaje_ejercido DESC;
