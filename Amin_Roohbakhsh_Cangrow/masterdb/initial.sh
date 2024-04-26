#!/bin/bash

docker compose -f ../docker-compose.yml up -d

docker exec -it db-master mariadb -u root -p'somewordpress' \
  -e "CREATE USER 'db-user'@'%' IDENTIFIED BY '123456789';" \
   "GRANT REPLICATION SLAVE ON *.* TO 'db-user'@'%';" \
   "SHOW MASTER STATUS;"

docker exec -it db-replica mariadb -u root -p'somewordpress' \
  -e "CREATE USER 'db-user-repl'@'%' IDENTIFIED BY '123456789';" \
   "GRANT REPLICATION SLAVE ON *.* TO 'db-user-repl'@'%';" \
   "SHOW MASTER STATUS;"


docker exec -it db-replica mariadb -u root -p'somewordpress' \
    -e " stop slave; \
    reset slave;\
    CHANGE MASTER TO MASTER_HOST='db-master', MASTER_USER='db-user', \
    MASTER_PASSWORD='123456789';\
    start slave;\
    SHOW SLAVE STATUS\G;"
        
docker exec -it db-master mariadb -u root -p'somewordpress' \
    -e " stop slave; \
    reset slave;\
    CHANGE MASTER TO MASTER_HOST='db-replica', MASTER_USER='db-user-repl', \
    MASTER_PASSWORD='123456789';\
    start slave;\
    SHOW SLAVE STATUS\G;"

#docker exec -it db_replica mariadb -u root -p'123456789' -e "START SLAVE;"
