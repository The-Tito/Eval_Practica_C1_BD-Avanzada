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
    s.id_solicitud,
    b.curp,
    b.nombre,
    be.fecha_cambio AS fecha_rechazo,
    COALESCE(be.motivo, 'Sin motivo registrado') AS motivo_rechazo

FROM bitacora_estados be
JOIN solicitudes s
    ON s.id_solicitud = be.id_solicitud
JOIN beneficiarios b
    ON b.id_beneficiario = s.id_beneficiario

WHERE
    be.estado_nuevo = 'Rechazada'
    AND be.fecha_cambio >= CURRENT_DATE - INTERVAL '90 days';
