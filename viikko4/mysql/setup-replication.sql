CREATE USER 'replicator'@'192.168.1.118' IDENTIFIED BY '<password>';
GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'192.168.1.118';

CREATE USER 'viikko4_reader'@'localhost' IDENTIFIED BY '<password>';
GRANT SELECT ON viikko2.counter TO 'viikko4_reader'@'localhost';
DROP USER IF EXISTS 'viikko2'@'localhost';

CHANGE REPLICATION SOURCE TO
  SOURCE_HOST = '192.168.1.228',
  SOURCE_USER = 'replicator',
  SOURCE_PASSWORD = '<password>',
  SOURCE_LOG_FILE = 'mysql-bin.000001',
  SOURCE_LOG_POS = 1056,
  GET_SOURCE_PUBLIC_KEY = 1;
START REPLICA;
SHOW REPLICA STATUS\G
