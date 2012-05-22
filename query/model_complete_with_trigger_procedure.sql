SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `ProyectoFinal` DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish2_ci ;
USE `ProyectoFinal` ;

-- -----------------------------------------------------
-- Table `ProyectoFinal`.`estados`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`estados` (
  `idEstado` INT NOT NULL ,
  `nombreEstado` VARCHAR(30) NOT NULL ,
  PRIMARY KEY (`idEstado`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ProyectoFinal`.`clientes`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`clientes` (
  `cedula` BIGINT(20) NOT NULL ,
  `nombres` VARCHAR(50) NOT NULL ,
  `apellidos` VARCHAR(50) NOT NULL ,
  `ciudad` VARCHAR(60) NOT NULL ,
  `barrio` VARCHAR(60) NOT NULL ,
  `direccion` VARCHAR(100) NOT NULL ,
  `telefono` BIGINT(20) NULL ,
  `celular` BIGINT(20) NULL ,
  `estados_idEstado` INT NOT NULL ,
  PRIMARY KEY (`cedula`) ,
  INDEX `fk_clientes_estado` (`estados_idEstado` ASC) ,
  CONSTRAINT `fk_clientes_estado`
    FOREIGN KEY (`estados_idEstado` )
    REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ProyectoFinal`.`facturas`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`facturas` (
  `noFactura` INT NOT NULL ,
  `vrFactura` DECIMAL(40,2) NOT NULL ,
  `fechaVencimiento` DATETIME NOT NULL ,
  `estados_idEstado` INT NOT NULL ,
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
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ProyectoFinal`.`pagos`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`pagos` (
  `idPago` INT NOT NULL AUTO_INCREMENT ,
  `vrPagado` DECIMAL(40,2) NOT NULL ,
  `fechaPago` DATETIME NOT NULL ,
  `idReversa` INT NOT NULL DEFAULT 0 ,
  `estados_idEstado` INT NOT NULL ,
  `facturas_noFactura` INT NOT NULL ,
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
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ProyectoFinal`.`saldofactura`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`saldofactura` (
  `idFactura` INT NOT NULL DEFAULT 0 ,
  `vrSaldo` DECIMAL(40,2) NOT NULL ,
  PRIMARY KEY (`idFactura`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- function usp_Pago_Factura
-- -----------------------------------------------------

DELIMITER $$
USE `ProyectoFinal`$$
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

DELIMITER ;
USE `ProyectoFinal`;

DELIMITER $$
USE `ProyectoFinal`$$


CREATE TRIGGER `saldo` BEFORE INSERT ON `facturas`
       FOR EACH ROW BEGIN
        INSERT INTO saldofactura SET idFactura = NEW.noFactura, vrSaldo = NEW.vrFactura;
     END$$


DELIMITER ;

CREATE USER `Usr_Final` IDENTIFIED BY 'final_usr';


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
