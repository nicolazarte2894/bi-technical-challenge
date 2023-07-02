USE AdventureWorks;

/*****REPORTE CON CONDICIONES*****/
	/* Fecha:
		- Ultimos 7 dias de venta
		- Formato de fecha "DD/MM/YYYY"
		- Orden del reporte por fecha descendiente
	*/
	/*Tarjeta de credito:
		- Que no sean del tipo "ColonialVoice"
	*/
	/*Duplicados Id de Venta:
		- Verifico valores duplicados en SalesOrderID: 31.465 registros distintos de ventas
		SELECT (select count(*) from (select * from Sales.SalesOrderHeader) as t) AS 'Cantidad de filas SalesOrderHeader', 
				(select count(distinct SalesOrderID) from Sales.SalesOrderHeader) AS 'Cantidad de SalesOrderID distintos'
		- A pesar de no tener duplicados en id de venta por tener la misma cantidad de filas que id, verifico a traves de particiones

	*/

-- Variable Fecha maxima
DECLARE @MaxDate AS date;
SELECT @MaxDate = MAX([Fecha de venta]) FROM reporte_ventas;
-- Common Table Exprassion para manejo de datos duplicados, condicion de fecha y tipo de tarjeta
WITH reporte_venta_semanal AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY [ID de Venta] ORDER BY [ID de Venta]) AS RowNum
    FROM reporte_ventas
	WHERE [Fecha de venta] >= DATEADD(DAY,-7,@MaxDate) AND [Tipo de tarjeta] != 'ColonialVoice'
)
SELECT FORMAT([Fecha de venta], 'dd-MM-yyyy') AS 'Fecha de venta', 
		-- ISNULL('Sin vendedor',[Nombre de Vendedor]) as 'Nombre de Vendedor',
		[Nombre de Vendedor],
		[Nombre de Cliente], 
		[ID de Venta], 
		[Cantidad productos vendidos], 
		[Cantidad de distintos productos vendidos], 
		[Monto total de la venta], 
		[Tipo de tarjeta], 
		[Tipo de Oferta]
FROM reporte_venta_semanal 
WHERE RowNum = 1
ORDER BY [Fecha de venta] DESC;