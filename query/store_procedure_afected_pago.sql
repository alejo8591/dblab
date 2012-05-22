-- --------------------------------------------------------------------------------
-- Procedimientos Group Routines
-- --------------------------------------------------------------------------------
DELIMITER $$

-- Creando funcion puesto que los procedimientos y las funciones trabajan 
-- parecido la diferencia es que las funciones devuelven datos y los procedimientos no
CREATE FUNCTION `proyectofinal`.`usp_Pago_Factura` (factura INT ,pago DECIMAL(40,2)) RETURNS INT
BEGIN
    -- declarando variables para los resultados de la consulta
    DECLARE resultado INT;
    DECLARE valor DECIMAL(40,2);
    
    -- Consulta para saber y comparar si la factura realmente esta presente 
		SELECT COUNT(noFactura) INTO resultado FROM facturas WHERE noFactura = factura;
    -- Consulta para traer el saldo de la factura según el trigger que exporta los datos
    -- a la tabla `saldofactura`
    SELECT vrSaldo INTO valor FROM saldofactura WHERE idFactura = factura;
    -- verificando si la factura esta creada o no    
    IF resultado = 0 THEN
        -- retorna 0 como se indica
        RETURN resultado;
    -- Si la factura esta presente lleva un valor de 1 en la variabre resultado
    ELSE
        -- verificando si el pago es menor o igual si no lo es retorna -1
        IF pago <= valor AND resultado = 1 THEN
             -- Se actualiza el valor del saldo correspondiente a la factura
             UPDATE saldofactura SET vrSaldo = (valor - pago) WHERE idFactura = factura;
             -- Se inserta el dato en `pagos` correspondiente al pago efectuado en `saldofactura`
             INSERT INTO pagos(vrPagado, fechaPago, idReversa, estados_idEstado, facturas_noFactura) VALUES (pago, NOW(), 0, 0, factura);
             RETURN resultado;
        ELSE
            -- Cuando el valor de la factura esta fuera del valor
            RETURN -1;
         END IF;
    END IF;
END $$

-- ------------------------------------------------------------------------------------------------
-- --------------------------Anular un pago-----------------------------------
-- ------------------------------------------------------------------------------------------------
-- Creando funcion puesto que los procedimientos y las funciones trabajan 
-- parecido la diferencia es que las funciones devuelven datos y los procedimientos no
DELIMITER //
CREATE FUNCTION `proyectofinal`.`usp_Anula_Pago` (id INT) RETURNS INT
BEGIN
    -- declarando variables para los resultados de la consulta
    DECLARE resultado INT;
    DECLARE factura INT;
    DECLARE valor DECIMAL(40,2);
    
    -- Consulta para saber y comparar si el pago realmente existe si existe pone en 1
    -- si no existe deja el valor en 0
		SELECT COUNT(idPago), facturas_noFactura INTO resultado, factura FROM pagos WHERE idPago = id;
    -- trayendo el valor pagado a la correspondiente factura
    SELECT vrPagado INTO valor FROM pagos WHERE idPago = id AND facturas_noFactura = factura;

    -- verificando si el pago fue creada   
    IF resultado = 0 THEN
        -- retorna 0 como se indica si el pago no existe
       RETURN resultado;
    -- Si el `idPago` del pago esta presente entonces realiza la siguiente accion
    ELSE 
       IF valor > 0 THEN
           UPDATE saldofactura SET vrSaldo = (valor + vrSaldo) WHERE idFactura = factura;
           UPDATE pagos SET idReversa = id, vrPagado = (-valor), fechaPago= NOW() WHERE idPago = id AND facturas_noFactura = factura;
           RETURN resultado;
       ELSE
         RETURN -1;
       END IF;
    END IF;
END //

-- ------------------------------------------------------------------------------------------------
-- --------------------------Lista de Factura de un Cliente-----------------------------------
-- ------------------------------------------------------------------------------------------------
-- Creando funcion puesto que los procedimientos y las funciones trabajan 
-- parecido la diferencia es que las funciones devuelven datos y los procedimientos no


DELIMITER $

CREATE PROCEDURE `proyectofinal`.`usp_Lista_Facturas` (cedula INT)
BEGIN
    -- Variable para contar las facturas del cliente
    DECLARE numFactura INT;
    -- Consulta para verificar la cantidad de facturas que tiene el cliente
    SELECT COUNT(noFactura) INTO numFactura FROM facturas WHERE clientes_cedula = cedula;
    -- Verificando si el cliente tiene facturas
    IF numFactura > 0 THEN
    -- Consulta los datos solicitados saldos al dia, saldo mayor a 0, y ordenar de la menor a la mayor fecha
    -- pendiente
     SELECT facturas.noFactura AS Factura, saldofactura.vrSaldo AS 'Saldo Factura', 
     facturas.fechaVencimiento AS 'Fecha Vencimiento', facturas.clientes_cedula AS 'Cedula Cliente' 
     FROM facturas INNER JOIN saldofactura ON facturas.noFactura = saldofactura.idFactura 
     WHERE saldofactura.vrSaldo > 0 AND facturas.clientes_cedula = cedula GROUP BY facturas.fechaVencimiento ASC;
    ELSE 
        -- en caso de que el cliente no tenga facuturas
        SELECT * FROM facturas WHERE clientes_cedula = cedula;
    END IF;
END $
-- ------------------------------------------------------------------------------------------------
-- --------------------------Lista de Pagos de un Cliente-----------------------------------
-- ------------------------------------------------------------------------------------------------
-- Creando funcion puesto que los procedimientos y las funciones trabajan 
-- parecido la diferencia es que las funciones devuelven datos y los procedimientos no

DELIMITER //

CREATE PROCEDURE `proyectofinal`.`usp_Lista_Pagos` (cedula INT)
BEGIN
    -- Variable para contar las facturas del cliente
    DECLARE numPago INT;
    -- Consulta para verificar la cantidad de facturas que tiene el cliente
    SELECT COUNT(idPago) INTO numPago FROM pagos INNER JOIN 
    facturas ON pagos.facturas_noFactura  = facturas.noFactura WHERE clientes_cedula = cedula;
    -- Verificando si el cliente tiene facturas
    IF numPago > 0 THEN
        SELECT pagos.idPago AS 'Numero del Pago', facturas.noFactura AS 'Numero Factura', pagos.vrPagado AS 'Valor Pagado', 
        pagos.fechaPago AS 'Fecha del Pago', pagos.estados_idEstado AS 'Estado'
        FROM pagos INNER JOIN facturas ON facturas.noFactura = pagos.facturas_noFactura 
        WHERE facturas.clientes_cedula = cedula;
    ELSE 
        SELECT * FROM pagos INNER JOIN facturas ON pagos.facturas_noFactura  = facturas.noFactura 
        WHERE facturas.clientes_cedula = cedula;
    END IF;
END //