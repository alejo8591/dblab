INSERT INTO facturas (noFactura, vrFactura, fechaVencimiento, estados_idEstado, clientes_cedula) VALUES (1234, 20000.2, '2012-12-12', 0, 80912070);
INSERT INTO facturas (noFactura, vrFactura, fechaVencimiento, estados_idEstado, clientes_cedula) VALUES (1235, 20090.2, '2012-12-12', 0, 80912090);
UPDATE facturas SET estados_idEstado = 1 WHERE clientes_cedula = 80912090; 
#Insertar con cedula no existente
#INSERT INTO facturas (noFacturas, vrFactura, fechaVencimiento, estados_idEstado, clientes_cedula) VALUES (1236, 20090.2, '2012-12-12', 0, 809120780);
SELECT * FROM facturas;