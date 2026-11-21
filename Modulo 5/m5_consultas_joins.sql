USE ventas_tech_db;

-- Consulta 1 — Vista base del proyecto (INNER JOIN)
-- Propósito: unificar en una sola tabla descriptiva las ventas con los datos del cliente, producto, categoría y ciudad para alimentar Power BI.
SELECT 
ven.fecha_venta AS [Fecha],
cli.id_cliente AS [Id del Cliente],
cli.nombre AS [Cliente],
cli.ciudad AS [Ciudad],
pro.nombre_producto AS [Producto],
cat.nombre_categoria AS [Categoria],
ven.cantidad AS [Cantidad],
ven.precio_unitario AS [Precio],
(ven.precio_unitario * ven.cantidad) AS Total

FROM ventas AS ven
INNER JOIN clientes AS cli 
ON cli.id_cliente = ven.id_cliente
INNER JOIN productos AS pro
ON pro.id_producto = ven.id_producto
INNER JOIN categorias AS cat
ON cat.id_categoria = pro.id_categoria;

-- Hallazgo: Se registran 10 ventas, donde la categoria "Computacion" es la que concentra mayor parte de la facturacion.


-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
-- Propósito: Detectar clientes registrados que nunca compraron, para que el área de CRM los contacte.
SELECT 
cli.nombre AS [Cliente],
cli.email AS [mail],
cli.fecha_registro AS [Fecha de Registro]
FROM clientes AS cli
LEFT JOIN ventas AS ven
ON cli.id_cliente = ven.id_cliente
WHERE ven.id_cliente IS NULL;

-- Hallazgo: Aparecieron 0 resultados. Para el área de CRM esto significa que al 100% de los clientes se les realizó una venta y el foco debe estar en fidelización.


-- Consulta 3 — Productos sin ventas (LEFT JOIN)
-- Propósito: Identificar los productos que nunca se vendieron para que el área de Producto planifique una estrategia de venta. 
SELECT 
pro.nombre_producto AS [Producto],
cat.nombre_categoria AS [Categoria],
pro.precio AS [Precio]
FROM productos AS pro
LEFT JOIN ventas AS ven
ON pro.id_producto = ven.id_producto
INNER JOIN categorias AS cat
ON cat.id_categoria = pro.id_categoria
WHERE ven.id_producto IS NULL;

-- Hallazgo: Aparecieron 0 productos sin ventas. Para el área de Producto esto implica que no hay artículos con stock inmovilizado ni sin rotación.


-- Consulta 4 — Consolidado por canal (UNION ALL)
-- Propósito: Saber qué cantidad de dinero se recauda en cada canal.
SELECT canal, SUM(total) AS total_canal
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Online' AS canal
    FROM ventas WHERE cantidad * precio_unitario > 1000
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, 'Presencial' AS canal
    FROM ventas WHERE cantidad * precio_unitario <= 1000
) AS consolidado
GROUP BY canal;

-- Hallazgo: El canal Online lidera la recaudación con $3,600.00, frente a $2,844.00 del canal Presencial.
