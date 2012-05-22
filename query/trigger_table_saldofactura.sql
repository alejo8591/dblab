-- Trigger DDL Statements
DELIMITER $$

USE `ProyectoFinal`$$

CREATE TRIGGER `saldo` BEFORE INSERT ON `facturas`
       FOR EACH ROW BEGIN
        INSERT INTO saldofactura SET idFactura = NEW.noFactura, vrSaldo = NEW.vrFactura;
     END$$