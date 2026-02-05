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
