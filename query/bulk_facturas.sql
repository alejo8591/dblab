LOAD DATA LOCAL INFILE 'C:/Users/usuario/Documents/db_final/data/facturas.csv'
INTO TABLE facturas
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n';

select * from facturas;