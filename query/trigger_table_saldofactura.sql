-- Trigger DDL Statements
DELIMITER $$

USE `ProyectoFinal`$$

CREATE TRIGGER `saldo` BEFORE INSERT ON `facturas`
       FOR EACH ROW BEGIN
       -- Instertando datos en la tabla `saldofactura` con respecto al 
       -- campo noFactura y su valor de factura vrFactura para modificar este campo y no 
       -- el original de la factura y lo mismo en pagos
        INSERT INTO saldofactura SET idFactura = NEW.noFactura, vrSaldo = NEW.vrFactura;
     END$$