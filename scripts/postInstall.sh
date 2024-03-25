#set env vars
set -o allexport; source .env; set +o allexport;

#wait until the server is ready
echo "Waiting for software to be ready ..."
sleep 30s;


curl https://${DOMAIN}/index/install/install \
  -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
  -H 'accept-language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7,he;q=0.6,zh-CN;q=0.5,zh;q=0.4,ja;q=0.3' \
  -H 'cache-control: no-cache' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'pragma: no-cache' \
  -H 'upgrade-insecure-requests: 1' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36' \
  --data-raw 'installing=0&adminUsername=admin&adminPassword='${ADMIN_PASSWORD}'&adminPassword2='${ADMIN_PASSWORD}'&adminEmail='${ADMIN_EMAIL}'&locale=en&timeZone=UTC&filesDir=%2Fvar%2Fwww%2Ffiles&databaseDriver=mysqli&databaseHost=172.17.0.1%3A56151&databaseUsername='${MYSQL_USER}'&databasePassword='${MYSQL_PASSWORD}'&databaseName='${MYSQL_DATABASE}'&oaiRepositoryId='${DOMAIN}'&enableBeacon=1&submitFormButton='

sleep 10s;

config=$(docker-compose exec -T ojs sh -c "cat /var/www/html/config.inc.php")
PWD=$(pwd)

cat config > $PWD/volumes/config/ojs.config.inc.php

docker-compose down;

sed -i "s~# - ./volumes/config/ojs.config.inc.php:/var/www/html/config.inc.php~- ./volumes/config/ojs.config.inc.php:/var/www/html/config.inc.php~g" ./docker-compose.yml

docker-compose up -d;