DELIMITER $$

CREATE FUNCTION `proyectofinal`.`usp_Pago_Factura` (factura INT ,pago DECIMAL(40,2)) RETURNS INT
BEGIN
    DECLARE resultado INT;
    DECLARE valor DECIMAL(40,2);

		SELECT COUNT(noFactura) INTO resultado FROM facturas WHERE noFactura = factura;
    SELECT vrSaldo INTO valor FROM saldofactura WHERE idFactura = factura;
        
    IF resultado = 0 THEN
        RETURN resultado;
    ELSE
        IF pago <= valor AND resultado = 1 THEN
             UPDATE saldofactura SET vrSaldo = (valor - pago) WHERE idFactura = factura;
             INSERT INTO pagos(vrPagado, fechaPago, idReversa, estados_idEstado, facturas_noFactura) VALUES (pago, NOW(), 0, 0, factura);
             RETURN 1;
        ELSE
            RETURN -1;
         END IF;
    END IF;
END $$
DELIMITER $$