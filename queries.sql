-- 1. Consulta con JOIN y Agregación (Monto por beneficiario)

-- Objetivo: Saber cuánto dinero en total ha recibido un beneficiario específico sumando todos sus programas.


SELECT 
    b.nombre, 
    b.apellido_paterno, 
    COUNT(e.id) AS total_entregas,
    SUM(e.monto_entregado) AS monto_acumulado
FROM beneficiarios b
JOIN entregas e ON b.id = e.id_beneficiario
GROUP BY b.id, b.nombre, b.apellido_paterno
HAVING SUM(e.monto_entregado) > 0; 

-- 2. Consulta con CASE y Subconsultas (Estatus de Solicitudes)

-- Objetivo: Listar solicitudes mostrandes si el evaluador no ha sido asignado.


SELECT 
    s.id AS folio_solicitud,
    b.curp,
    COALESCE(ev.nombre, 'PENDIENTE DE ASIGNAR') AS evaluador_responsable,
    CASE 
        WHEN s.estado = 'Aprobada' THEN 'Trámite Finalizado con Éxito'
        WHEN s.estado = 'Rechazada' THEN 'Trámite Finalizado - No Elegible'
        ELSE 'En Proceso Administrativo'
    END AS estatus_informativo
FROM solicitudes s
JOIN beneficiarios b ON s.id_beneficiario = b.id
LEFT JOIN evaluadores ev ON s.id_evaluador_asignado = ev.id;


-- 3. Consulta de Historial (Uso de la Entidad Débil)

-- Objetivo: Ver el recorrido de una solicitud específica (por ejemplo, la de Juana Ramírez) para ver quién cambió su estado y por qué.


SELECT 
    be.fecha_cambio,
    be.estado_anterior,
    be.estado_nuevo,
    ev.nombre AS realizado_por,
    COALESCE(be.motivo, 'No se registró motivo') AS observacion
FROM bitacora_estados be
JOIN evaluadores ev ON be.id_usuario_cambio = ev.id
WHERE be.id_solicitud = 1 
ORDER BY be.fecha_cambio DESC;


-- 4. Consulta de "Campo Justo" (Apoyos en Especie)

-- Objetivo: Mostrar qué productos se entregaron en un programa específico que maneja apoyos físicos.


SELECT 
    p.nombre AS programa,
    ee.descripcion_producto,
    SUM(ee.cantidad) AS cantidad_total_repartida
FROM programas p
JOIN entregas e ON p.id = e.id_programa
JOIN entregas_especie ee ON e.id = ee.id_entrega
WHERE p.nombre = 'Campo Justo'
GROUP BY p.nombre, ee.descripcion_producto;