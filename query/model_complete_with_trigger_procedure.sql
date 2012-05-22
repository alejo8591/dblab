SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `ProyectoFinal` DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish2_ci ;

USE `ProyectoFinal`;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`clientes` (
  `cedula` BIGINT(20) NOT NULL ,
  `nombres` VARCHAR(50) NOT NULL ,
  `apellidos` VARCHAR(50) NOT NULL ,
  `ciudad` VARCHAR(60) NOT NULL ,
  `barrio` VARCHAR(60) NOT NULL ,
  `direccion` VARCHAR(100) NOT NULL ,
  `telefono` BIGINT(20) NULL DEFAULT NULL ,
  `celular` BIGINT(20) NULL DEFAULT NULL ,
  `estados_idEstado` INT(11) NOT NULL ,
  PRIMARY KEY (`cedula`) ,
  INDEX `fk_clientes_estado` (`estados_idEstado` ASC) ,
  CONSTRAINT `fk_clientes_estado`
    FOREIGN KEY (`estados_idEstado` )
    REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`facturas` (
  `noFactura` INT(11) NOT NULL ,
  `vrFactura` DECIMAL(40,2) NOT NULL ,
  `fechaVencimiento` DATETIME NOT NULL ,
  `estados_idEstado` INT(11) NOT NULL ,
  `clientes_cedula` BIGINT(20) NOT NULL ,
  PRIMARY KEY (`noFactura`) ,
  INDEX `fk_factura_estado1` (`estados_idEstado` ASC) ,
  INDEX `fk_factura_cliente1` (`clientes_cedula` ASC) ,
  CONSTRAINT `fk_factura_estado1`
    FOREIGN KEY (`estados_idEstado` )
    REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_factura_cliente1`
    FOREIGN KEY (`clientes_cedula` )
    REFERENCES `ProyectoFinal`.`clientes` (`cedula` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`pagos` (
  `idPago` INT(11) NOT NULL AUTO_INCREMENT ,
  `vrPagado` DECIMAL(40,2) NOT NULL ,
  `fechaPago` DATETIME NOT NULL ,
  `idReversa` INT(11) NOT NULL DEFAULT 0 ,
  `estados_idEstado` INT(11) NOT NULL ,
  `facturas_noFactura` INT(11) NOT NULL ,
  PRIMARY KEY (`idPago`) ,
  INDEX `fk_pago_estado1` (`estados_idEstado` ASC) ,
  INDEX `fk_pago_factura1` (`facturas_noFactura` ASC) ,
  CONSTRAINT `fk_pago_estado1`
    FOREIGN KEY (`estados_idEstado` )
    REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_pago_factura1`
    FOREIGN KEY (`facturas_noFactura` )
    REFERENCES `ProyectoFinal`.`facturas` (`noFactura` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`estados` (
  `idEstado` INT(11) NOT NULL ,
  `nombreEstado` VARCHAR(30) NOT NULL ,
  PRIMARY KEY (`idEstado`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`saldofactura` (
  `idFactura` INT(11) NOT NULL DEFAULT 0 ,
  `vrSaldo` DECIMAL(40,2) NOT NULL ,
  PRIMARY KEY (`idFactura`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;


DELIMITER $$
USE `ProyectoFinal`$$
-- Creando funcion puesto que los procedimientos y las funciones trabajan 
-- parecido la diferencia es que las funciones devuelven datos y los procedimientos no
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
       UPDATE saldofactura SET vrSaldo = (valor + vrSaldo) WHERE idFactura = factura;
       UPDATE pagos SET idReversa = id, vrPagado = (-valor), fechaPago= NOW() WHERE idPago = id AND facturas_noFactura = factura;
       RETURN resultado;
    END IF;
END $$

DELIMITER ;

DELIMITER $$
USE `ProyectoFinal`$$
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

DELIMITER ;

DELIMITER $$

USE `ProyectoFinal`$$


CREATE TRIGGER `saldo` BEFORE INSERT ON `facturas`
       FOR EACH ROW BEGIN
       -- Instertando datos en la tabla `saldofactura` con respecto al 
       -- campo noFactura y su valor de factura vrFactura para modificar este campo y no 
       -- el original de la factura y lo mismo en pagos
        INSERT INTO saldofactura SET idFactura = NEW.noFactura, vrSaldo = NEW.vrFactura;
     END$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
