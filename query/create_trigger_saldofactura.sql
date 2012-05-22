SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER SCHEMA `ProyectoFinal`  DEFAULT CHARACTER SET utf8  DEFAULT COLLATE utf8_spanish2_ci ;

USE `ProyectoFinal`;

ALTER TABLE `ProyectoFinal`.`facturas` CHANGE COLUMN `fechaVencimiento` `fechaVencimiento` DATETIME NOT NULL  , DROP FOREIGN KEY `fk_factura_estado1` ;

ALTER TABLE `ProyectoFinal`.`facturas` 
  ADD CONSTRAINT `fk_factura_estado1`
  FOREIGN KEY (`estados_idEstado` )
  REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE `ProyectoFinal`.`pagos` CHANGE COLUMN `fechaPago` `fechaPago` DATETIME NOT NULL  ;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`saldofactura` (
  `facturas_noFactura` INT(11) NOT NULL ,
  `vrSaldo` DECIMAL(40,2) NOT NULL ,
  INDEX `fk_saldofactura_facturas1` (`facturas_noFactura` ASC) ,
  PRIMARY KEY (`facturas_noFactura`) ,
  CONSTRAINT `fk_saldofactura_facturas1`
    FOREIGN KEY (`facturas_noFactura` )
    REFERENCES `ProyectoFinal`.`facturas` (`noFactura` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;


DELIMITER $$

USE `ProyectoFinal`$$


CREATE TRIGGER saldo BEFORE INSERT ON facturas
      FOR EACH ROW BEGIN
        INSERT INTO saldofactura SET noFactura = saldofactura.facturas_noFactura;
        INSERT INTO saldofactura SET vrFactura = saldofactura.vrSaldo;
      END$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
