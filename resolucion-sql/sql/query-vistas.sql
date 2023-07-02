USE AdventureWorks;
GO
/******VISTAS******/
-- Manejo de errores de vistas
IF OBJECT_ID('lista_vendedores', 'V') IS NOT NULL DROP VIEW lista_vendedores;
IF OBJECT_ID('lista_clientes', 'V') IS NOT NULL DROP VIEW lista_clientes;
IF OBJECT_ID('lista_productos', 'V') IS NOT NULL DROP VIEW lista_productos;
IF OBJECT_ID('reporte_ventas', 'V') IS NOT NULL DROP VIEW reporte_ventas;
GO
-- Lista de Vendedores
CREATE VIEW lista_vendedores AS 
							(
							SELECT DISTINCT 
									soh.SalesPersonID, 
									(pp.FirstName +' ' + pp.LastName) AS 'Nombre de Vendedor'
							FROM Sales.SalesOrderHeader soh
							JOIN Person.Person pp ON  pp.BusinessEntityID = soh.SalesPersonID
							);
GO
-- Lista Compradores
CREATE VIEW lista_clientes AS
							(
							SELECT 
									sc.CustomerID, 
									COALESCE(ss.Name, CONCAT(pp.FirstName,' ',pp.LastName)) AS 'Nombre de Cliente'
							FROM Sales.Customer sc
							LEFT JOIN Sales.Store ss ON ss.BusinessEntityID = sc.StoreID
							LEFT JOIN Person.Person pp ON pp.BusinessEntityID = sc.PersonID
							); 
GO
-- Lista Cantidad de productos vendidos y distintos productos vendidos por orden de venta
CREATE VIEW lista_productos AS
							(
							SELECT 
									SalesOrderID, 
									SUM(OrderQty) AS 'Cantidad productos vendidos', 
									COUNT(DISTINCT ProductID) AS 'Cantidad de distintos productos vendidos', 
									MAX(SpecialOfferID) AS SpecialOfferID
							FROM Sales.SalesOrderDetail
							GROUP BY SalesOrderID
							);
GO
-- Reporte de total ventas
CREATE VIEW reporte_ventas AS 
							(
							SELECT 
									soh.OrderDate AS 'Fecha de venta', 
									lv.[Nombre de Vendedor],
									soh.SalesOrderID AS 'ID de Venta', 
									lc.[Nombre de Cliente], 
									lp.[Cantidad productos vendidos], 
									lp.[Cantidad de distintos productos vendidos], 
									soh.TotalDue AS 'Monto total de la venta',
									cc.CardType AS 'Tipo de tarjeta', 
									CASE WHEN lp.SpecialOfferID = 1 THEN 'No' ELSE 'Si' END AS 'Oferta',
									so.Type AS 'Tipo de Oferta'
							FROM Sales.SalesOrderHeader soh
							LEFT JOIN lista_vendedores lv ON lv.SalesPersonID = soh.SalesPersonID
							LEFT JOIN lista_clientes lc ON lc.CustomerID = soh.CustomerID
							LEFT JOIN lista_productos lp ON lp.SalesOrderID = soh.SalesOrderID
							LEFT JOIN Sales.CreditCard cc ON cc.CreditCardID = soh.CreditCardID 
							LEFT JOIN Sales.SpecialOffer so ON so.SpecialOfferID = lp.SpecialOfferID
							);
GO

