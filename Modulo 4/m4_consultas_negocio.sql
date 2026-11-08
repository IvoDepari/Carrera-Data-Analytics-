USE ventas_tech_db

-- Consulta 1 — Resumen ejecutivo mensual

SELECT MONTH(fecha_venta) AS 'Mes',
SUM(cantidad * precio_unitario) AS 'Total Facturado',
COUNT(id_venta) AS 'Cantidad de Pedidos', 
SUM(cantidad * precio_unitario) / COUNT(id_venta) AS 'Ticket Promedio' 
FROM ventas
GROUP BY MONTH(fecha_venta);


-- Consulta 2 — Ranking de productos

SELECT TOP 5
id_producto AS 'Productos más vendidos',
SUM(cantidad) AS 'Unidades vendidas',
SUM(cantidad * precio_unitario) AS 'Total generado' 
FROM ventas
GROUP BY id_producto
ORDER BY [Total generado] DESC

-- Consulta 3 — Clientes recurrentes

SELECT 
id_cliente, 
COUNT(id_cliente) AS 'Cantidad de pedidos', 
SUM(cantidad * precio_unitario) AS 'Total gastado' 
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1

-- Consulta 4 — Productos por encima/por debajo del promedio

WITH Totales_Por_Producto AS (
-- Paso 1: Calculamos el total facturado por cada producto individual
    SELECT 
        id_producto, 
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
-- Paso 2: Comparamos cada producto contra el promedio global de esos totales
SELECT 
id_producto,
total_facturado,
CASE 
	WHEN total_facturado > (SELECT AVG(total_facturado) FROM Totales_Por_Producto) THEN 'Por encima'
	ELSE 'Por debajo'
END AS 'Promedio de facturacion'
FROM Totales_Por_Producto


-- === BLOQUE DE CIERRE: 3 Hallazgos Concretos ===
-- 1. Concentración de ingresos: El producto 1 (Laptop Pro 15) es por lejos el producto estrella, generando $3,600 (más del 50% de la facturación total del mes).
-- 2. Retención perfecta: Al revisar la Consulta 3, observamos que absolutamente todos los clientes (los 5) son recurrentes, con exactamente 2 pedidos cada uno en el mes de marzo.
-- 3. Desigualdad de catálogo: En la Consulta 4, solo 2 productos (el ID 1 y el ID 3) logran superar el promedio general de facturación por producto, mientras que los 4 restantes quedaron por debajo.
