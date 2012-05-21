LOAD DATA LOCAL INFILE 'C:/Users/usuario/Documents/db_final/data/clientes.csv'
INTO TABLE clientes
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n';

select * from clientes;