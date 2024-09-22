CREATE USER 'koha'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'koha'@'localhost';
FLUSH PRIVILEGES;
