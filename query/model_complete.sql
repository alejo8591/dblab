SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `ProyectoFinal` DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish2_ci ;

USE `ProyectoFinal`;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`clientes` (
  `cedula` INT(11) NOT NULL ,
  `nombres` VARCHAR(50) NOT NULL ,
  `apellidos` VARCHAR(50) NOT NULL ,
  `ciudad` VARCHAR(60) NOT NULL ,
  `barrio` VARCHAR(60) NOT NULL ,
  `direccion` VARCHAR(100) NOT NULL ,
  `telefono` INT(11) NULL DEFAULT NULL ,
  `celular` INT(11) NULL DEFAULT NULL ,
  `estados_idEstado` INT(11) NOT NULL ,
  PRIMARY KEY (`cedula`) ,
  INDEX `fk_clientes_estados` (`estados_idEstado` ASC) ,
  CONSTRAINT `fk_clientes_estados`
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
  `fechaVencimiento` DATE NOT NULL ,
  `estados_idEstado` INT(11) NOT NULL ,
  `clientes_cedula` INT(11) NOT NULL ,
  PRIMARY KEY (`noFactura`) ,
  INDEX `fk_facturas_estados1` (`estados_idEstado` ASC) ,
  INDEX `fk_facturas_clientes1` (`clientes_cedula` ASC) ,
  CONSTRAINT `fk_facturas_estados1`
    FOREIGN KEY (`estados_idEstado` )
    REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_facturas_clientes1`
    FOREIGN KEY (`clientes_cedula` )
    REFERENCES `ProyectoFinal`.`clientes` (`cedula` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish2_ci;

CREATE  TABLE IF NOT EXISTS `ProyectoFinal`.`pagos` (
  `idPago` INT(11) NOT NULL ,
  `vrPagado` DECIMAL(40,2) NOT NULL ,
  `fechaPago` DATE NOT NULL ,
  `idReversa` INT(11) NOT NULL DEFAULT 0 ,
  `estados_idEstado` INT(11) NOT NULL ,
  `facturas_noFacturas` INT(11) NOT NULL ,
  PRIMARY KEY (`idPago`) ,
  INDEX `fk_pagos_estados1` (`estados_idEstado` ASC) ,
  INDEX `fk_pagos_facturas1` (`facturas_noFacturas` ASC) ,
  CONSTRAINT `fk_pagos_estados1`
    FOREIGN KEY (`estados_idEstado` )
    REFERENCES `ProyectoFinal`.`estados` (`idEstado` )
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fk_pagos_facturas1`
    FOREIGN KEY (`facturas_noFacturas` )
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


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
