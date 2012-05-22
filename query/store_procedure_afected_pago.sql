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
DELIMITER $$