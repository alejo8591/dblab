SELECT usp_Pago_Factura(1234, 15000.20)
SELECT * FROM saldofactura;
SELECT * FROM facturas; usp_Pago_Factura
SELECT COUNT(noFactura) FROM facturas WHERE noFactura = 34;
SELECT vrSaldo FROM saldofactura WHERE idFactura = 12;
SELECT NOW()
select * from pagos;
select * from saldofactura;

SELECT usp_Pago_Factura(1235, 5090)
-- ID DE RECIEN PAGO
SELECT MAX(idPago), vrPagado FROM pagos WHERE facturas_noFactura=1235;