LOAD DATA LOCAL INFILE 'C:/Documents and Settings/xp/Mis documentos/GitHub/dblab/data/facturas.csv'
INTO TABLE facturas
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n';

select * from facturas;