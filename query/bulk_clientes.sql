LOAD DATA LOCAL INFILE 'C:/Documents and Settings/xp/Mis documentos/GitHub/dblab/data/clientes.csv'
INTO TABLE clientes
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n';

select * from clientes;