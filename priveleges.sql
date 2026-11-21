-- [!] OBS: para evitar problemas de permissionamento, execute o script abaixo
-- estando logado com o seu usuário 'root' do MySQL.

DROP USER IF EXISTS 'flowtech_api_user'@'%', 'flowtech_etl_user'@'%', 'flowtech_client_user'@'%';

CREATE USER IF NOT EXISTS 'flowtech_api_user'@'%' IDENTIFIED BY 'Sptech#2026_Api';
GRANT SELECT, EXECUTE, INSERT, UPDATE, DELETE ON flowtech.* TO 'flowtech_api_user'@'%';
SHOW GRANTS FOR 'flowtech_api_user'@'%';

CREATE USER IF NOT EXISTS 'flowtech_etl_user'@'%' IDENTIFIED BY 'Sptech#2026_Etl';
GRANT SELECT ON flowtech.* TO 'flowtech_etl_user'@'%';
SHOW GRANTS FOR 'flowtech_etl_user'@'%';

CREATE USER IF NOT EXISTS 'flowtech_client_user'@'%' IDENTIFIED BY 'Sptech#2026_Client';
GRANT SELECT ON flowtech.* TO 'flowtech_client_user'@'%';
SHOW GRANTS FOR 'flowtech_client_user'@'%';

FLUSH PRIVILEGES;
SELECT User FROM mysql.user;